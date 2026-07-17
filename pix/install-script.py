#!/usr/bin/env python3
# Merges one <script> element into Pix's scripts.xml (~/.config/pix/scripts.xml)
# without disturbing any other Personalize scripts the user has defined --
# Pix owns this file (rewrites it whenever it saves its own state), so this
# only ever inserts/replaces by id, never overwrites the whole file.

import sys
import xml.etree.ElementTree as ET

new_script_path, target_path = sys.argv[1], sys.argv[2]
new_script = ET.parse(new_script_path).getroot()
script_id = new_script.get("id")

try:
    tree = ET.parse(target_path)
    root = tree.getroot()
except (FileNotFoundError, ET.ParseError):
    root = ET.Element("scripts", version="1.1")
    tree = ET.ElementTree(root)

for existing in root.findall("script"):
    if existing.get("id") == script_id:
        root.remove(existing)

root.append(new_script)
tree.write(target_path, encoding="UTF-8", xml_declaration=True)
