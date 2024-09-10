import os
import urllib.parse
from collections import namedtuple
import re

def tryint(s):
	try:
		return int(s)
	except:
		return s

def alphanum_key(s):
	""" Turn a string into a list of string and number chunks.
		"z23a" -> ["z", 23, "a"]
	"""
	return [ tryint(c) for c in re.split('([0-9]+)', s) ]

SCENES_DIR = 'scenes'
THUMBS_DIR = 'scenes/.algodoo_thumbs'

Scene = namedtuple('Scene', ['name', 'scene_path', 'thumb_path'])

def find_scenes():
	scenes = []
	for root, dirs, files in os.walk(SCENES_DIR):
		for file in files:
			if file.endswith('.phz'):
				scene_path = os.path.join(root, file)
				thumb_path = os.path.join(THUMBS_DIR, file + '.png')
				if not os.path.exists(thumb_path):
					thumb_path = None
				scene_name = file[:-4]
				scenes.append(Scene(scene_name, scene_path, thumb_path))
	return scenes

def path_to_relative_url(path: str) -> str:
	# Replace backslashes with forward slashes (for Windows paths)
	path = path.replace("\\", "/")
	# URL-encode the path (this ignores forward slashes by default)
	return urllib.parse.quote(path, safe="/")

def generate_markdown(scenes):
	markdown = ''

	# sort by name, numerically where version numbers are present, and otherwise alphabetically
	scenes.sort(key=lambda scene: alphanum_key(scene.name))

	# sort by whether there is a thumbnail
	scenes.sort(key=lambda scene: scene.thumb_path is None)

	for scene_name, scene_path, thumb_path in scenes:
		scene_url_path = path_to_relative_url(scene_path)
		if thumb_path:
			thumb_url_path = path_to_relative_url(thumb_path)
			markdown += f'[![{scene_name}]({thumb_url_path})]({scene_url_path})\n'
		else:
			markdown += f'- [{scene_name}]({scene_url_path})\n'
	return markdown

def main():
	scenes = find_scenes()
	markdown = generate_markdown(scenes)
	print(markdown)

if __name__ == '__main__':
	main()
