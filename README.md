This is a somewhat modified sample code from [session 509 WWDC 2016](https://developer.apple.com/videos/play/wwdc2016/509) on speech recognition

![](https://raw.github.com/zats/SpeechRecognition/master/website/screen.gif)

The goal of this demo is to generate real time subtitles by recognizing the audio feed from the video while playing it back.

## Important notes

1. While I used [this video from Realm Live](https://realm.wistia.com/medias/u3xprtodqi) as a sample, all copyrights belong to their respective owners. It was the video I saw on Twitter when I came up with this idea, plus it has a clear audio track (kudos to Chris) which makes it easier to recognize speech. Also sorry for the video asset, it is quite big - 23Mb.

2. Recognition is happening locally on device **every time** you are playing video, so it might be good if you are broadcasting a live interview, but probably not such a great idea if you are Netflix and can generate subtitles videos before publishing.

3. `SFSpeechRecognizer` doesn't seem to be designed with this usecase in mind, it is intended more for short interactions with your app such as a voice command or a search query dictation. It stops recognizing voice after a certain time (currently around 1 minute). In this sample I am simply recreating 

4. Many thanks to engineers from AVFoundation, CoreAudio, SiriKit and SpeechRecognition teams for helping to figure out details of this demo, without them this demo would not exist!