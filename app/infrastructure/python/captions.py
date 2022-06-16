import sys
from youtube_transcript_api import YouTubeTranscriptApi

captions = YouTubeTranscriptApi.get_transcript(sys.argv[1])
captions_text = "".join([caption['text'] for caption in captions])

print(captions_text)
