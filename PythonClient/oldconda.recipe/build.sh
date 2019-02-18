#!/bin/bash

cd $RECIPE_DIR/..
$PYTHON oldsetup.py install --single-version-externally-managed --record=record.txt

rm record.txt
