#!/bin/bash

cd $RECIPE_DIR/../PythonClient
$PYTHON setup.py install --single-version-externally-managed --record=record.txt

rm record.txt
