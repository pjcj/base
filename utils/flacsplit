#!/usr/bin/env python3

# Requires python 3.6 for the "encoding" parameter for Popen and for
# os.path.commonpath to accept a sequence of path-like objects

"""Split a flac file with cuesheet and embedded tags into multiple
files, optionally re-encoded as mp3.
"""

version = "0.3"

import os
import os.path
import subprocess
import re
import sys
import argparse
import pathlib
import itertools
import multiprocessing

class flactags:
    def __init__(self, path):
        self.tags = {}
        mf = subprocess.Popen(["metaflac", "--export-tags-to=-", str(path)],
                              stdout=subprocess.PIPE, encoding="utf-8")
        tags, xxx = mf.communicate()
        if mf.returncode != 0:
            return
        taglines = [x.strip() for x in tags.split("\n")]
        for x in taglines:
            s = x.split('=', 1)
            if len(s) != 2:
                continue
            tag, value = s
            self.tags[tag] = value

    def get_tag(self, tag, track):
        track_value = self.tags.get(f"{tag}[{track}]")
        default_value = self.tags.get(tag)
        return track_value or default_value

class cuesheet:
    """The cuesheet will tell us how many tracks are present.  We
    ignore the timing information because we will be using the --cue
    option to flac to select each track.  If there is no cuesheet we
    will treat this as a single-track file.

    """
    def __init__(self, path):
        mf = subprocess.Popen(["metaflac","--export-cuesheet-to=-", str(path)],
                              stdout=subprocess.PIPE, encoding="utf-8")
        cues, xxx = mf.communicate()
        if mf.returncode != 0:
            if args.verbose:
                print("no cuesheet in '%s'; assuming single track" % path)
            self.tracks = {1: None}
            self.lasttrack = 1
            return
        cuelines = [x.strip() for x in cues.split("\n")]
        tracks = {}
        tracknum = None
        for x in cuelines:
            m = re.search(r'TRACK (\d\d) AUDIO', x)
            if m != None:
                tracknum = int(m.groups()[0])
                tracks[tracknum] = None
                continue
            m = re.search(r'ISRC (.*)', x)
            if m != None:
                tracks[tracknum] = m.groups()[0]
        self.tracks = tracks
        self.lasttrack = tracknum

class picture:
    """flac files may contain one or more embedded pictures
    """
    def __init__(self, path):
        mf = subprocess.Popen(["metaflac","--export-picture-to=-", str(path)],
                              stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        picture, xxx = mf.communicate()
        if mf.returncode != 0:
            if args.verbose:
                print("no picture in '%s'" % path)
            self.data = None
            return
        assert isinstance(picture, bytes)
        self.data = picture

def fatsafe(name):
    invalid_fat_characters = ['?', ':', '|', '"', '*']
    for i in invalid_fat_characters:
        name = name.replace(i, '')
    return name

class flacfile:
    def __init__(self, file_with_info):
        path, inputbase, args = file_with_info
        self.path = path
        self.args = args

        self.cuesheet = cuesheet(path)
        self.tags = flactags(path)
        self.picture = picture(path)
        self.jobs = []

        if args.verbose:
            print("%s: %d tracks in file." % (path, self.cuesheet.lasttrack))

        outdir = args.outputdir
        if args.keepdirs:
            relative = path.relative_to(inputbase) if inputbase \
                       else path
            # If the fatsafe flag is specified, every component that we add
            # to the output path must be fatsafe
            if args.fatsafe:
                for part in relative.parent.parts:
                    outdir = outdir / fatsafe(part)
            else:
                outdir = outdir.joinpath(relative.parent)
        if args.subdir:
            if args.fatsafe:
                outdir = outdir / fatsafe(path.stem)
            else:
                outdir = outdir / path.stem

        self.badtracks = []
        for track in range(1, self.cuesheet.lasttrack + 1):
            if track not in self.cuesheet.tracks:
                self.badtracks.append(
                    "track %d not present" % track)
                continue
            title = self.tags.get_tag('TITLE', track)
            artist = self.tags.get_tag('ARTIST', track)
            if not title:
                self.badtracks.append("track %d is missing TITLE tag" % track)
                continue
            if not artist:
                self.badtracks.append("track %d is missing ARTIST tag" % track)
                continue
            if args.verbose:
                print("%02d: %s by %s" % (
                    track, title, artist))
            outfilename = "%02d %s (%s)" % (
                track, title, artist)
            outfilename = outfilename.replace(os.sep, '')
            if args.fatsafe:
                outfilename = fatsafe(outfilename)
            if args.max_filename_length:
                # This is somewhat clunky, but hopefully won't come up
                # too often!  The limit on filename length is on the
                # number of bytes the filename encodes to, but we can
                # only remove a whole number of characters
                while len(outfilename.encode('utf-8')) > args.max_filename_length:
                    outfilename = outfilename[:-1]
            outfilename = outfilename + ".mp3"
            outputfile = outdir / outfilename
            try:
                output_mtime = outputfile.stat().st_mtime
            except:
                output_mtime = 0
            if args.update:
                input_mtime = self.path.stat().st_mtime
                if output_mtime > input_mtime:
                    if args.verbose:
                        print("  - skipping %s because it is newer" % outputfile)
                    continue
            self.jobs.append((self, track, outputfile))

    @staticmethod
    def process_job(jobinfo):
        self, tracknum, outputfile = jobinfo
        # Make sure the output directory exists
        outputfile.parent.mkdir(parents=True, exist_ok=True)
        outputtmpfile = outputfile.with_suffix(".tmp")
        pictmpfile = None
        fields = [('TITLE', '--tt', "{}"),
                  ('ARTIST', '--ta', "{}"),
                  ('ALBUM', '--tl', "{}"),
                  ('DATE', '--ty', "{}"),
                  ('TRACKNUMBER', '--tn', "{}"),
                  ('ALBUMARTIST', '--tv', "TPE2={}"),
        ]
        id3opts = []
        for name, opt, template in fields:
            tag = self.tags.get_tag(name, tracknum)
            if tag:
                id3opts.append(opt)
                id3opts.append(template.format(tag))
        # Add album art if present
        if self.picture.data:
            pictmpfile = outputfile.with_suffix(".tmppic")
            with open(pictmpfile, 'wb') as f:
                f.write(self.picture.data)
            id3opts.append('--ti')
            id3opts.append(str(pictmpfile))

        flac = subprocess.Popen(
            ["flac", "--decode",
             "--totally-silent",
             "--cue=%d.1-%d.1" % (tracknum, tracknum + 1),
             "--output-name=-", str(self.path)],
            stdout=subprocess.PIPE)
        lame = subprocess.Popen(
            ["lame", "--preset", args.lamepreset, "--silent"] + id3opts + [
                "-", str(outputtmpfile)],
            stdin=flac.stdout)
        lame.communicate()
        flac.wait()
        lame.wait()
        if pictmpfile:
            pictmpfile.unlink()
        if flac.returncode != 0 or lame.returncode != 0:
            try:
                outputtmpfile.unlink()
            except:
                pass
            return ("Error writing %s: flac returncode %d, "
                    "lame returncode %d" % (outputfile, flac.returncode,
                                            lame.returncode))
        try:
            outputtmpfile.rename(outputfile)
        except:
            return ("Error renaming tmp file %s to %s" %(
                outputtmpfile, outputfile))
        return "%s track %d -> %s" % (self.path, tracknum, outputfile)

if __name__ == '__main__':
    if sys.version_info < (3, 6):
        print("{} requires python 3.6 or later".format(sys.argv[0]), file=sys.stderr)
        sys.exit(1)
    parser = argparse.ArgumentParser(
        description="Split flac files into multiple mp3 files")
    parser.add_argument('--version', action='version', version=version)
    parser.add_argument(
        "-o", "--output-dir", action="store", type=pathlib.Path,
        dest="outputdir", help="Output directory, default '.'",
        default=pathlib.Path.cwd())
    parser.add_argument(
        "-v", "--verbose", action="store_true", dest="verbose",
        help="Show track lists and progress details",
        default=False)
    parser.add_argument(
        "-k", "--keep-directory-structure", action="store_true",
        dest="keepdirs", help="Reproduce the directory structure "
        "of the input when creating the output files",
        default=False)
    parser.add_argument(
        "-s", "--subdir", action="store_true",
        dest="subdir", help="Create the output files in a "
        "directory named after the input file; ignored if "
        "the input file only contains one track", default=False)
    parser.add_argument(
        "-f", "--fat-safe", action="store_true", dest="fatsafe",
        help="Remove characters from output pathnames that "
        "are not safe for FAT filesystems", default=False)
    parser.add_argument(
        "-t", "--truncate-filenames", action="store", type=int,
        dest="max_filename_length", default=None,
        help="Truncate output filenames (excluding extension) to this length in bytes")
    parser.add_argument(
        "-n", "--skip-newer", action="store_true", dest="update",
        help="Do not overwrite an output file if it is "
        "newer than the input file", default=False)
    parser.add_argument(
        "-c", "--continue-on-error", action="store_true",
        help="Continue working after an error and report all "
        "the errors at the end", dest="cont", default=False)
    parser.add_argument(
        "-p", "--lame-preset", action="store", type=str,
        dest="lamepreset", default="extreme",
        help="Preset to pass to lame, default 'extreme'")
    parser.add_argument(
        "-j", "--jobs", action="store", type=int, default=os.cpu_count(),
        help="Number of tracks to work on in parallel")
    inputs = parser.add_mutually_exclusive_group()
    inputs.add_argument(
        "-x", "--from-stdin", action="store_true", dest="fromstdin",
        help="Read list of filenames from stdin, one per line")
    inputs.add_argument(
        "-0", "--null", action="store_true", dest="null",
        help="Read list of filenames from stdin, each terminated by "
        "a null character.  The GNU find -print0 option produces input "
        "suitable for this mode.")

    parser.add_argument('filenames', metavar='filename.flac', type=str,
                        nargs='*', help="file to process")

    args = parser.parse_args()

    if (args.fromstdin or args.null) and args.filenames:
        parser.error("You can't specify filenames on the command line and "
                     "also read them from stdin")
        sys.exit(1)

    if args.fromstdin:
        filesource = sys.stdin.read()
        filenames = filesource.split('\n')
    elif args.null:
        filesource = sys.stdin.read()
        filenames = filesource.split('\0')
    else:
        filenames = args.filenames

    files = [ pathlib.Path(x) for x in filenames if x ]

    if len(files) < 1:
        parser.error("please supply at least one input filename")

    inputbase = os.path.commonpath(files)
    inputbase = pathlib.Path(inputbase) if inputbase else None

    if not args.outputdir.is_dir():
        print("Output location '%s' is not a directory" % args.outputdir)
        sys.exit(1)

    pool = multiprocessing.Pool(args.jobs)

    files_with_info = ((f, inputbase, args) for f in files)
    flacs = list(pool.imap_unordered(flacfile, files_with_info))
    jobs = itertools.chain.from_iterable((f.jobs for f in flacs))
    statuses = pool.imap_unordered(flacfile.process_job, jobs)

    try:
        for s in statuses:
            print(s)

        for f in flacs:
            if f.badtracks:
                print("%s problems:" % f.path)
                for t in f.badtracks:
                    print("  %s" % t)

    except KeyboardInterrupt:
        # The workers might not get a chance to tidy up their temporary files
        print("Exiting - output temporary files may be incomplete")
        pool.terminate()

    pool.close()
    pool.join()
