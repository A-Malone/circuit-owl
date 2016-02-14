import requests
import json
import multiprocessing
import os
from PIL import Image
import io

#------------------------------------------------------------
#--------------------------CONFIG----------------------------
#------------------------------------------------------------

# Query
query = "finite state machine"
start_index = 1
num_results = 100

# Output files
start_number = 101
out_directory = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'resistor', 'neg', 'img')
out_format = "png"
#------------------------------------------------------------

def get_file(args):
    num, url = args

    filename, file_extension = os.path.splitext(url)

    out_file = os.path.join(out_directory, "{}{}".format(num, file_extension))

    with open(out_file, 'wb') as handle:
        response = requests.get(url, stream=True)

        if not response.ok:
            return False

        for block in response.iter_content(1024):
            handle.write(block)

    if (file_extension[1:] != out_format):
        correct_out_file = os.path.join(out_directory, "{}.{}".format(num, out_format))
        Image.open(out_file).save(correct_out_file, format=out_format.upper())
        os.remove(out_file)

keys = None
with open("keys.secret") as f:
    keys = json.load(f)

current_index = start_index

payload = {
    'key':keys["key"],
    'cx': keys["cx"],
    'q': query,
    'start': current_index,
    'count': 10,
    'searchType': 'image',
    'fileType':'png',
    'imgColorType':'gray'
    }
url = "https://www.googleapis.com/customsearch/v1"


file_urls = []

while current_index < num_results + 1:

    r = requests.get(url, params=payload)

    resp_json = r.json()
    try:
        payload["start"] = resp_json["queries"]["nextPage"][0]["startIndex"]
    except KeyError as e:
        break

    for item in resp_json["items"]:
        try:
            file_urls.append(item["link"])
            print(item["link"])
        except KeyError as e:
            pass

        current_index += 1
        if(current_index > num_results):
            break

pool = multiprocessing.Pool(processes=min(4, num_results))
results = pool.imap_unordered(get_file, zip(range(start_number, num_results + start_number), file_urls))
for i in results:
    pass
