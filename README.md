# Movie-manager
Movie-manager is a platform independent desktop application that manages the movie files that you have on your computer, NAS or on any other drive. It will index the paths you supply and will try to match the files with an IMDb entry. If not succesfull you can also match files manually by supplying a title, IMDb url or IMDb ID.

Movie-manager supports transcoding of your movie files. This feature was added by incorporating [WinFF] (http://winff.org). This application is a wrapper around ffmpeg which is also written in FPC like movie-manager. The support is now very basic, but it works fine. In the future I will incorporate WinFF more tightly so it becomes an integral part.

You can also play your movie files directly from movie-manager, provided you have ffplay in your search path.

Some future features of movie-manager are;
- subtitle downloading
- database support to allow caching of movie information (currently worked on)
- multiple movie web database support
- file management: this feature will allow to reorganize your distributed movie files into a new library folder, this is usefull if you have a lot of distributed files or a lot of subfolders and other files that you want to get rid of

# How it all started
Well, I just couldn't find a proper movie manager software that was platform independent and had the features I was looking for. Sure IMDb lookup is a common feature, but it was the renaming, file-management and transcoding that I was looking for. As it happens implementing this was pretty trivial and I got to the first commit in a couple of short coding sessions over a few days.

I decided to put everything to GitHub so others can enjoy it as well. I do not provide binaries, although if you ask me kindly I could be tempted to do so.

If you like coding and would like to improve this software then please be my guest. If you just have some ideas about the software then file an inssue in the tracker! I will be glad to implement almost everything, as long as it's feasable.

My goal with this software to become the best movie manager in the world!!!  Hahaha, no not really. As long as it suits my needs I'm happy. Cheers!
