import importlib

yaml = importlib.import_module("yaml")

with open(
    "config/portfolio.yml",
    "r",
    encoding="utf-8"
) as f:

    cfg = yaml.safe_load(f)
