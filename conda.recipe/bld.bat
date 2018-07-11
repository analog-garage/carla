%PYTHON% setup.py --quiet install --build-js --single-version-externally-managed --record=record.txt
if errorlevel 1 exit 1

del record.txt
