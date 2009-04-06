# mkdeb-workflow.sh
#
#
# create DEB files of rear
#

WORKFLOW_mkdeb_DESCRIPTION="Create DEB packages with this rear version"
WORKFLOWS=( ${WORKFLOWS[@]} mkdeb )
WORKFLOW_mkdeb () {

	type -p dpkg >/dev/null || Error "Please install 'dpkg' into your PATH."

	# create dist archives
	WORKFLOW_mkdist

	pkg_size="$(du -s $TMP_DIR/$prod_ver/|awk -F " " '{print $1}')"
	ProgressStart "Creating DEB packages "
	
	tar -C $TMP_DIR -xzvf $distarchive 1>&8
	# prod_ver is the same here as in mkdist, so the directory names should match
	mkdir -v $TMP_DIR/$prod_ver/DEBIAN/ 
	ProgressStopIfError $? "Could not mkdir '$TMP_DIR/$prod_ver/DEBIAN/'"
	
	rm $TMP_DIR/$prod_ver/doc
	rm $TMP_DIR/$prod_ver/CHANGES
	rm $TMP_DIR/$prod_ver/README
	ProgressStopIfError $? "Could not delete symlinks in'$TMP_DIR/$prod_ver/'"

	cat > $TMP_DIR/$prod_ver/DEBIAN/control <<-EOF
	Package: rear
	Version: $VERSION
	Architecture: all
	Section: misc
	Priority: optional
	Essential: no
	Depends: mingetty, nfs-common, syslinux, mkisofs, binutils
	Installed-Size: 1740
	Maintainer: Fridtjof Busse <fridtjof@fbunet.de>
	Provides: rear
	Description: Relax And Recover desaster recovery solution
	EOF

	cat > $TMP_DIR/$prod_ver/DEBIAN/conffiles <<-EOF
	/etc/rear/local.conf
	/etc/rear/site.conf
	EOF

	dpkg -b "$TMP_DIR/$prod_ver" /tmp/$prod_ver.deb 2>&1 | tee /dev/fd/8 /dev/fd/2|grep '\.deb$' >$TMP_DIR/rpmbuild

	ProgressStopOrError $PIPESTATUS "Could not build DEB. See '$LOGFILE' for more information."

	echo "Wrote '/tmp/$prod_ver.deb'"

	LogPrint "$(cat $TMP_DIR/debbuild)"
}