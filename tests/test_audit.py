from pathlib import Path

def test_tools_exist():

    tools = [
        "tools/audit_portfolio.py",
        "tools/export_link_errors_csv.py",
        "tools/portfolio_compliance_report.py",
        "tools/validate_markdown_links.py",
    ]

    for tool in tools:

        assert Path(tool).exists()

