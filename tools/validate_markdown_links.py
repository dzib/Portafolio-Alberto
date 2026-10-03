from pathlib import Path
import re

ROOT = Path.cwd()

PATTERN = re.compile(r'!?\[[^\]]*\]\(([^)]+)\)')

markdown_files = list(ROOT.rglob("*.md"))

total_links = 0
broken_links = []

for md_file in markdown_files:

    try:
        content = md_file.read_text(
            encoding="utf-8",
            errors="ignore"
        )
    except Exception:
        continue

    links = PATTERN.findall(content)

    for link in links:

        total_links += 1

        if (
            link.startswith("http://")
            or link.startswith("https://")
            or link.startswith("mailto:")
            or link.startswith("#")
        ):
            continue

        target_link = link.split("#")[0]

        target_path = (
            md_file.parent / target_link
        ).resolve()

        if not target_path.exists():

            broken_links.append(
                (
                    str(md_file.relative_to(ROOT)),
                    target_link,
                )
            )

print("\n==============================")
print(" Markdown Link Validation")
print("==============================\n")

print(f"Markdown Files : {len(markdown_files)}")
print(f"Links Found    : {total_links}")
print(f"Broken Links   : {len(broken_links)}")

if broken_links:

    print("\nBroken Links Detected:\n")

    for file_name, missing_link in broken_links:

        print(file_name)
        print(f"  -> {missing_link}")
        print()
else:

    print("\n✅ No broken links found.")
