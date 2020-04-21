#!/usr/local/bin/liquidsoap

# Standard settings
# set("log.file.path","/tmp/radio.log")
set("log.stdout",true)
# set("log.file",true)
set("server.telnet",true)
set("server.telnet.bind_addr","0.0.0.0")
set("init.allow_root", true)

# Stream Settings

dj_password = getenv("DJ_PASSWORD")
icecast_host = getenv("ICECAST_HOST")
icecast_password = getenv("ICECAST_PASSWORD")
api_host = getenv("API_HOST")
playlist_file = getenv("PLAYLIST_FILE")

backup = playlist(reload=1,reload_mode="rounds",mode="randomize",playlist_file)
jingles = playlist(reload=1,reload_mode="rounds",mode="randomize","/MUSIC/JINGLES")
jingles = nrj(jingles)
jingles = mksafe(jingles)

dj = input.harbor("dj",port=8082,password=dj_password,id="dj")
#podcast = input.harbor("podcast",port=8082,password="XTRadioP455",id="podcast")

interval = random.float(min=3120.0,max=3130.0)
timed_jingles=delay(interval,jingles)

def send_meta(m) =
ignore(http.get("http://" ^ api_host ^ "/post/song?file=" ^ url.encode(m["filename"]) ^ "&artist=" ^ url.encode(m["artist"]) ^ "&title=" ^ url.encode(m["title"]) ^ ""))
#ignore(http.get("http://air.radiotime.com/Playing.ashx?partnerId=v9JFLEaB&partnerKey=0unVe3mWpxNq&id=s182867&title=" ^ url.encode(m["title"]) ^ "&artist=" ^ url.encode(m["artist"]) ^ "  > /dev/null 2>&1 "))
#  ignore(system("/var/www/MAIN/API/upcoming.sh > /dev/null 2>&1 "))
#  ignore(system("ttytter -status=\"♪ #np: " ^ m["artist"] ^ " - " ^ m["title"] ^ " / Listen @ https://xtradio.org\" > /dev/null 2>&1"))
# ignore(system("php /scripts/sendtweet.php artist=" ^ url.encode(m["artist"]) ^ " title=" ^ url.encode(m["title"]) ^ " filename=" ^ url.encode(m["filename"]) ^ " > /dev/null 2>&1"))
end

radio = backup
#radio = random(weights = [1, 5], [delay(1.,jingles), radio])
radio = fallback(track_sensitive=true, [request.queue(id="request"),radio])
#radio = smart_crossfade(radio)
# radio = smart_crossfade(start_next=10., fade_in=8., fade_out=10., high=-15.,medium=-32., margin=4., width=3., conservative=false, radio)
radio = nrj(radio)
radio = mksafe(radio)
radio = amplify(1.,override="replay_gain",radio)

radio = smooth_add(p=0.3, delay=0.5, special=timed_jingles, normal=radio)

#radio = map_metadata(map, radio)

def dj_title(m) =
  title = m["title"]
  [("title","#{title} / Live DJ")]
end
dj = map_metadata(dj_title, dj)

#def podcast_meta(m)
#  title = m["title"]
#  [("title","#{title} / Podcast")]
#end
#podcast = map_metadata(podcast_meta, podcast)

#radio = fallback(track_sensitive=false, [podcast,radio])
radio = fallback(track_sensitive=false, [dj,radio])

radio = on_metadata(send_meta, radio)

# Now output the stream to the local icecast server in mp3 and ogg format (Debian needed a recompile to allow vorbis and mp3 encoding)
# {% for data in mountpoints %}
# output.icecast(%{% if data.type == "audio/mpeg" %}mp3{% elif data.type == "audio/aac" %}fdkaac{%endif%}(bitrate={{ data.quality }}), host="icecast",port={{ icecast_port }},
# password="{{ icecast_admin_password }}",mount="{{ data.mount }}",url="XTRadio.ORG",
# description="We Love MusiC! Do U?! - {{ data.quality }}kbps/{{ data.type }}/Stereo - https://XTRadio.ORG",radio)
# {% endfor %}

output.icecast(%mp3(bitrate=128), host=icecast_host,port=8080,
password=icecast_password,mount="low.mp3",url="XTRadio.ORG",
description="We Love MusiC! Do U?! - 128kbps/MP3/Stereo - https://XTRadio.ORG",radio)

output.icecast(%mp3(bitrate=192), host=icecast_host,port=8080,
password=icecast_password,mount="mid.mp3",url="XTRadio.ORG",
description="We Love MusiC! Do U?! - 192kbps/MP3/Stereo - https://XTRadio.ORG",radio)

output.icecast(%mp3(bitrate=320), host=icecast_host,port=8080,
password=icecast_password,mount="high.mp3",url="XTRadio.ORG",
description="We Love MusiC! Do U?! - 320kbps/MP3/Stereo - https://XTRadio.ORG",radio)

output.icecast(%fdkaac(bitrate=32), host=icecast_host,port=8080,
password=icecast_password,mount="aac",url="XTRadio.ORG",
description="We Love MusiC! Do U?! - 32kbps/AAC/Stereo - https://XTRadio.ORG",radio)

#Crossfade
#def smart_crossfade (~start_next=5.,~fade_in=3.,~fade_out=3.,
#                     ~default=(fun (a,b) -> sequence([a, b])),
#                     ~high=-15., ~medium=-32., ~margin=4.,
#                     ~width=2.,~conservative=false,s)
#  fade.out = fade.out(type="sin",duration=fade_out)
#  fade.in  = fade.in(type="sin",duration=fade_in)
#  add = fun (a,b) -> add(normalize=false,[b, a])
#  log = log(label="smart_crossfade")
#
#  def transition(a,b,ma,mb,sa,sb)
#
#    list.iter(fun(x)-> log(level=4,"Before: #{x}"),ma)
#    list.iter(fun(x)-> log(level=4,"After : #{x}"),mb)
#
#    if ma["type"] == "jingles" or mb["type"] == "jingles" then
#      log("Old or new file is a jingle: sequenced transition.")
#      sequence([sa, sb])
#    elsif
#      # If A and B are not too loud and close, fully cross-fade them.
#      a <= medium and b <= medium and abs(a - b) <= margin
#    then
#      log("Old <= medium, new <= medium and |old-new| <= margin.")
#      log("Old and new source are not too loud and close.")
#      log("Transition: crossed, fade-in, fade-out.")
#      add(fade.out(sa),fade.in(sb))
#
#    elsif
#      # If B is significantly louder than A, only fade-out A.
#      # We don't want to fade almost silent things, ask for >medium.
#      b >= a + margin and a >= medium and b <= high
#    then
#      log("new >= old + margin, old >= medium and new <= high.")
#      log("New source is significantly louder than old one.")
#      log("Transition: crossed, fade-out.")
#      add(fade.out(sa),sb)
#
#    elsif
#      # Opposite as the previous one.
#      a >= b + margin and b >= medium and a <= high
#    then
#      log("old >= new + margin, new >= medium and old <= high")
#      log("Old source is significantly louder than new one.")
#      log("Transition: crossed, fade-in.")
#      add(sa,fade.in(sb))
#
#    elsif
#      # Do not fade if it's already very low.
#      b >= a + margin and a <= medium and b <= high
#    then
#      log("new >= old + margin, old <= medium and new <= high.")
#      log("Do not fade if it's already very low.")
#      log("Transition: crossed, no fade.")
#      add(sa,sb)
#
#    # What to do with a loud end and a quiet beginning ?
#    # A good idea is to use a jingle to separate the two tracks,
#    # but that's another story.
#
#    else
#      # Otherwise, A and B are just too loud to overlap nicely,
#      # or the difference between them is too large and overlapping would
#      # completely mask one of them.
#      log("No transition: using default.")
#      default(sa, sb)
#    end
#  end
#
#  smart_cross(width=width, duration=start_next, conservative=conservative,
#              transition,s)
#end

def map( m )

   # Get filename from file path
   dollar = string.extract(pattern="([^/]*)\..*$_", m["filename"])
   filename = dollar["1"]

   # Construct stream metadata from available id3 tags
  if ( m["title"] == "" ) then
      [ ("artist", "New"), ("title", filename) ]
   else
      if ( m["album"] != "" ) then
         if ( m["artist"] != "" ) then
            if int_of_string( m["year"], default = 0 ) > 0 then
               [ ("title", m["album"]^" ("^m["year"]^") - "^m["title"] ) ]
            else
               [ ("title", m["album"]^" - "^m["title"] ) ]
            end
         else
            [ ("artist", "New"), ("title", m["album"]^" - "^m["title"] ) ]
         end
      else
         [ ("title", m["title"] ) ]
      end
   end

end
