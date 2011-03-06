AC_PREREQ([2.65])
AC_INIT([sl-installer], 
        m4_esyscmd([(pre=; if test -d ../../.git -a ! -d .git; then pre=$PWD/; cd ../..; fi; \
                    ${pre}build-aux/version-gen \
                    ${pre}build-aux/tarball-version \
                    ${pre}build-aux/package-version)]), 
        [sl-users@nic.surfnet.nl])
AC_CONFIG_AUX_DIR([build-aux])

AC_PREFIX_DEFAULT([/opt/svp])

AC_PROG_INSTALL
AC_PROG_MKDIR_P
AC_PROG_LN_S
AC_PROG_GREP
AC_PROG_SED

#
# The canonical build name is needed to specialize $FETCH below.
#
AC_CANONICAL_BUILD

#
# Find a known URL retrieve program.
#
AC_ARG_VAR([FETCH], [URL retrieve command])
if test -z "$FETCH"; then 
  # not provided by user, try to figure out
  AC_PATH_PROGS([FETCH], [wget curl])
fi
if test -z "$FETCH"; then
  AC_MSG_WARN([Cannot find a URL retrieve command. Archive files must be placed manually into distfiles/.])
  FETCH="${am_missing_run}wget"
fi

case $FETCH in
     *curl*) FETCH="$FETCH -s ";;
     *wget*) FETCH="$FETCH -q -O - " ;;
esac

#
# If using the default URL, do not check SSL certificate.
#
AC_ARG_VAR([DIST_SITE], [base URL to retrieve source archives])
default_site=https://dist.svp-home.org/deploy
if test "x$DIST_SITE" = "x"; then
   DIST_SITE=$default_site
   case $FETCH in
      *wget*) FETCH="$FETCH --no-check-certificate" ;;
      *curl*) FETCH="$FETCH -k" ;;
   esac
fi
AC_ARG_VAR([TAGS_SITE], [base URL to retrieve version number database])
default_tags_site=https://dist.svp-home.org/sl-tags
if test "x$TAGS_SITE" = "x"; then
   TAGS_SITE=$default_tags_site
   case $FETCH in
      *wget*) FETCH="$FETCH --no-check-certificate" ;;
      *curl*) FETCH="$FETCH -k" ;;
   esac
fi

#
# Look for GNU make, before initializing Automake.
#
AC_ARG_VAR([MAKE], [path to GNU make])
AC_CACHE_CHECK([for GNU make], [ac_cv_path_MAKE],
[if ${MAKE-make} --version 2>/dev/null | $ac_path_GREP GNU >/dev/null; then
  ac_cv_path_MAKE=${MAKE-make}
else
  AC_PATH_PROGS_FEATURE_CHECK([MAKE], [make gmake gnumake],
    [[$ac_path_MAKE --version 2>/dev/null | $ac_path_GREP GNU >/dev/null && ac_cv_path_MAKE=$ac_path_MAKE ac_path_MAKE_found=:]],
    [AC_MSG_ERROR([could not find GNU make])])
fi
])
AC_SUBST([MAKE], [$ac_cv_path_MAKE])

# The following should appear *after* checking for GNU make above.
AM_INIT_AUTOMAKE([1.11 foreign dist-bzip2 silent-rules])
AM_SILENT_RULES([yes])

AC_PROG_CC
AC_PROG_CXX

AC_CACHE_CHECK([for Bourne-Again shell], [ac_cv_path_BASH],
	[AC_PATH_PROGS_FEATURE_CHECK([BASH], [bash3 bash sh],
	[[$ac_path_BASH -c 'test "x$BASH_VERSION" != "x"' \
             && ac_cv_path_BASH=$ac_path_BASH ac_path_BASH_found=:]],
	[AC_MSG_ERROR([could not find bash])])])
AC_SUBST([BASH], [$ac_cv_path_BASH])

#
# If MacPorts is installed, assume it should be used.
# Also, fish for GNU getopt on MacOS X 10.5+.
#
case $build in
  *-apple-darwin*)
  AC_MSG_CHECKING([for MacPorts])
  if test -d /opt/local/var/macports; then
    AC_MSG_RESULT([yes]) 
    CPPFLAGS="$CPPFLAGS -I/opt/local/include"
    LDFLAGS="$LDFLAGS -L/opt/local/lib"
  else
    AC_MSG_RESULT([no])
  fi
  ;;
esac

AC_ARG_WITH([tagfile],
            [AC_HELP_STRING([--with-tagfile=NAME],
                            [use version information from tag NAME (download if necessary, default "latest")])],
            [], [with_tagfile=latest])

if ! test -r "$with_tagfile"; then
   # tag file not really there yet, try to fetch
   tagsource=$TAGS_SITE/$with_tagfile
   $MKDIR_P tags
   rm -f tags/"$with_tagfile"
   AC_MSG_NOTICE([trying to download $tagsource...])
   if ! ($FETCH "$tagsource" >tags/"$with_tagfile"); then
      rm -f tags/"$with_tagfile"
      AC_MSG_WARN([could not fetch $tagsource, trying local file...])
      if test -r "$with_tagfile.dist"; then
         AC_MSG_NOTICE([$with_tagfile.dist -> tags/$with_tagfile])
         cp "$with_tagfile.dist" tags/"$with_tagfile"
      elif test -r "$srcdir/$with_tagfile.dist"; then
         AC_MSG_NOTICE([$srcdir/$with_tagfile.dist -> tags/$with_tagfile])
         cp "$srcdir/$with_tagfile.dist" tags/"$with_tagfile"
      else
         AC_MSG_ERROR([cannot find provider $tagsource, consider using --with-tagfile])
      fi
   fi
else
   AC_MSG_NOTICE([$with_tagfile -> tags/$with_tagfile])
   cp -f "$with_tagfile" tags/"$with_tagfile"
fi

# here the tagfile exists, extract the information
AC_MSG_NOTICE([using version information from "tags/$with_tagfile"])
for x in `grep -v "^\#" < "tags/$with_tagfile"`; do
   var=`echo "$x"|cut -d: -f1`
   val=`echo "$x"|cut -d: -f2-`
   eval "def_${var}_ver='$val'"
done

m4_define([handle_package],[
AC_ARG_WITH([$1-version], 
            [AC_HELP_STRING([--with-$1-version=VVV], 
                            [use version VVV for $1 (default: ]def_$1_ver[)])],
            [], [with_$1_version=$def_$1_ver])
AC_ARG_WITH([$1-archive],
            [AC_HELP_STRING([--with-$1-archive=ARCH],
                            [use file ARCH for $1 (default: distfiles/]m4_ifblank([$2],[$1],[$2])[-VVV.tar.bz2)])],
            [], [with_$1_archive=distfiles/m4_ifblank([$2],[$1],[$2])-$with_$1_version.tar.bz2])

the_dir=`dirname "$with_$1_archive"`
mkdir -p "$the_dir" || true
the_dir=`(cd "$the_dir" && pwd)`
the_name=$the_dir/`basename "$with_$1_archive"`
the_name=`echo "$the_name" | sed -e 's|^'"$PWD"'/||'`
with_$1_archive=$the_name

m4_toupper($1)_VERSION=$with_$1_version
m4_toupper($1)_ARCHIVE=$with_$1_archive
AC_SUBST(m4_toupper($1)_VERSION)
AC_SUBST(m4_toupper($1)_ARCHIVE)
])

handle_package([binutils])
handle_package([gcc])
handle_package([mgsim])
handle_package([slc], [sl-core])
handle_package([m4])

for v in SL_TAG SLREQS_TAG CC_ALPHA_OVERRIDE \
   UTCC_ALPHA_OVERRIDE AR_MTALPHA_OVERRIDE RANLIB_MTALPHA_OVERRIDE \
   CC_SPARC_OVERRIDE UTCC_SPARC_OVERRIDE AR_MTSPARC_OVERRIDE \
   RANLIB_MTSPARC_OVERRIDE SLC_DATADIR SLC_LIBDIR SLC_INCDIR \
   MGSIM_ALPHA MGSIM_SPARC; do
   val=`eval echo 'x$'$v`
   if test "$val" != x; then
       AC_MSG_ERROR([Variable $v is set. Please unset (or deslenv) before running configure again.])
   fi
done

AC_CONFIG_FILES([Makefile slenv deslenv slversion])
AC_OUTPUT

echo "*"
echo "* Configuration done."
echo "*"
echo "* Destination dir:    $prefix"
echo "* Archive repository: $DIST_SITE"
echo "* URL fetch cmd:      $FETCH"
echo "* GNU make:           $MAKE"
echo "* C compiler:         $CC $CPPFLAGS $CFLAGS $LDFLAGS"
echo "* C++ compiler:       $CXX $CPPFLAGS $CXXFLAGS $LDFLAGS"
echo "*"
echo "* mg-binutils:        $BINUTILS_ARCHIVE ($BINUTILS_VERSION)"
echo "* GCC (patched):      $GCC_ARCHIVE ($GCC_VERSION)"
echo "* m4 (patched):       $M4_ARCHIVE ($M4_VERSION)"
echo "* mgsim:              $MGSIM_ARCHIVE ($MGSIM_VERSION)"
echo "* slc:                $SLC_ARCHIVE ($SLC_VERSION)"
echo "*"
echo "Now run:"
echo 
echo "    $MAKE install"
echo "or"
echo "    $MAKE help"
echo 