#!/usr/bin/env bash
sqlite3 ../mira_ng/db/development.sqlite3 ".dump sipity_entities" | sqlite3 db/development.sqlite3
sqlite3 ../mira_ng/db/development.sqlite3 ".dump sipity_workflows" | sqlite3 db/development.sqlite3
