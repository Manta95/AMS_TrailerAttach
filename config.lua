ConfigTrailer = {}

-- ATTACH ANY TRAILER TO CAR (Only cars with a tow hitch bone will work)
ConfigTrailer.AnyTrailerAttach = true
    ConfigTrailer.AfterDetachCooldown = 5000 -- cooldown in ms to not attach the trailer again after it is detached
    ConfigTrailer.DistanceFromTowHitch = 2.0 -- max distance from the car's tow hitch to the trailer's tow hitch for attaching
    ConfigTrailer.MaxSpeedForAttach = 5.0 -- max vehicle speed (km/h) to search for nearby trailers
