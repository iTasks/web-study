#!/usr/bin/env python3

import argparse
import csv
import json
from collections import defaultdict


def build_summary(input_path: str) -> dict:
    totals = defaultdict(float)
    counts = defaultdict(int)
    with open(input_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            book = (row.get("book") or "UNKNOWN").strip() or "UNKNOWN"
            amount = float(row.get("amount") or 0)
            totals[book] += amount
            counts[book] += 1

    books = []
    for book in sorted(totals):
        books.append(
            {
                "book": book,
                "records": counts[book],
                "totalAmount": round(totals[book], 2),
            }
        )

    return {
        "bookCount": len(books),
        "totalRecords": sum(counts.values()),
        "books": books,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Build reconciliation summary from transaction CSV")
    parser.add_argument("--input", required=True, help="Input transaction CSV file")
    parser.add_argument("--out", required=True, help="Output summary JSON path")
    args = parser.parse_args()

    summary = build_summary(args.input)
    with open(args.out, "w", encoding="utf-8") as out_file:
        json.dump(summary, out_file, indent=2)
    print(f"Wrote reconciliation summary to {args.out}")


if __name__ == "__main__":
    main()
