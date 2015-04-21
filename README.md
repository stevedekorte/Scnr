# Scnr
Music discovery app - look up an artists, browse tracks by similar artists, remember likes and dislikes

# iTunes Store and local APIs

All requests go through the shared SCTunesCache instance which handles caching and talking to the local iTunes API to access the list of owned tracks.

The iTunes Store API doesn't share the "users who bought album X, also bought album Y" info, so this is scraped from the ablum pages on the iTunes Store web site as needed.

# Persistence and caching

SCTunesCache: 
    - caches iTunes related URL requests, expires in 30 days 
    - caches iTunes track records permenantly
    - caches are stored in the "~/Applications Support/Scnr" folder

LikeDB:
    - SCArtist uses a likeDB instance for storing artist like/dislikes    
    - SCTrack uses a likeDB instance for storing track like/dislikes
    - like dbs are stored in the "~/Applications Support/Scnr" folder

# Playing samples

The iTunes Store API returns preview urls for the tracks and SCTrackView uses AVPlayer to stream them.

# How the UI works

AppDelegate and SCTrackView are the only UI classes - everying else uses naked objects via NavNodeKit to directly browse the model data