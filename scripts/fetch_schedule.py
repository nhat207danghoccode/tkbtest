#!/usr/bin/env python3
"""Fetch public school timetable data and store static weekly JSON snapshots."""
from __future__ import annotations
import json
import os
import sys
import time
from datetime import date, datetime, timedelta, timezone
from pathlib import Path

import requests

BASE = "https://phongdaotao.cdytehatinh.edu.vn"
OUT = Path("data")
TZ = timezone(timedelta(hours=7))
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/126.0.0.0 Safari/537.36",
    "Accept": "application/json, text/plain, */*",
    "Referer": BASE + "/xem-lich-hoc/lich-cong-khai",
}


def monday(d: date) -> date:
    return d - timedelta(days=d.weekday())


def school_config(d: date):
    start = d.year if d.month >= 8 else d.year - 1
    return f"{start} - {start + 1}", 1 if d.month >= 8 else 2


def get_json(session: requests.Session, path: str, params: dict):
    url = BASE + path
    response = session.get(url, params=params, headers=HEADERS, timeout=35)
    if response.status_code == 404:
        return 404, None
    response.raise_for_status()
    content_type = response.headers.get("content-type", "")
    try:
        return response.status_code, response.json()
    except ValueError as exc:
        preview = response.text[:180].replace("\n", " ")
        raise RuntimeError(f"API trả nội dung không phải JSON ({response.status_code}, {content_type}): {preview}") from exc


def fetch_week(session: requests.Session, week: date):
    school_year, semester = school_config(week + timedelta(days=3))
    params = {"date": week.isoformat(), "schoolYear": school_year, "semester": str(semester)}
    status, payload = get_json(session, "/api/attendance/general-schedules/week", params)
    if status != 404:
        return payload, "weekly-api"

    # Compatibility fallback used by the school's own public page.
    daily = []
    for offset in range(7):
        day = week + timedelta(days=offset)
        daily_params = {
            "date": day.isoformat(),
            "schoolYear": school_year,
            "semester": str(semester),
        }
        if offset == 0:
            daily_params["includePlannedSubjects"] = "true"
        _, day_payload = get_json(session, "/api/attendance/general-schedules", daily_params)
        daily.append(day_payload)
        time.sleep(0.15)
    return daily, "daily-api-fallback"


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    today = datetime.now(TZ).date()
    current = monday(today)
    # Cache two weeks before and twelve weeks after the current week.
    weeks = [current + timedelta(weeks=i) for i in range(-2, 13)]
    session = requests.Session()
    successes = 0
    failures = []
    for week in weeks:
        target = OUT / f"week-{week.isoformat()}.json"
        try:
            payload, method = fetch_week(session, week)
            record = {
                "ok": True,
                "weekStart": week.isoformat(),
                "fetchedAt": datetime.now(TZ).isoformat(timespec="seconds"),
                "source": method,
                "data": payload,
            }
            target.write_text(json.dumps(record, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
            successes += 1
            print(f"OK {week}: {method}")
        except Exception as exc:
            failures.append(f"{week}: {exc}")
            print(f"ERROR {week}: {exc}", file=sys.stderr)
            # Keep the last good snapshot if the upstream server is temporarily unavailable.
            if not target.exists():
                target.write_text(json.dumps({"ok": False, "weekStart": week.isoformat(), "error": str(exc)}, ensure_ascii=False), encoding="utf-8")
    status = {
        "updatedAt": datetime.now(TZ).isoformat(timespec="seconds"),
        "weeksTotal": len(weeks),
        "weeksUpdated": successes,
        "errors": failures,
    }
    (OUT / "status.json").write_text(json.dumps(status, ensure_ascii=False, indent=2), encoding="utf-8")
    if successes == 0:
        raise SystemExit("Không lấy được tuần lịch nào từ máy chủ trường.")
    if failures:
        print(f"Hoàn tất một phần: {successes}/{len(weeks)} tuần; xem data/status.json")
    else:
        print(f"Hoàn tất: {successes}/{len(weeks)} tuần.")


if __name__ == "__main__":
    main()
