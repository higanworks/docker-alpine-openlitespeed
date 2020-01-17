#!/bin/sh
# APKBUILD.package()

set -xeu

pkgname=litespeed
_pkgreal=open$pkgname
pkgver=${PKGVER}
builddir=/usr/src/openlitespeed-$pkgver
pkgusers=litespeed
pkggroups=litespeed
pkgdir=/
_pkghome=var/lib/$pkgname
_php=php7

package() {
	local file;
	cd "$builddir"
	make DESTDIR="$pkgdir" install

	mkdir -p "$pkgdir"/usr/lib/$pkgname \
		"$pkgdir"/usr/sbin \
		"$pkgdir"/var/log

	# remove trash
	rm -fr "$pkgdir"/$_pkghome/php* \
		"$pkgdir"/$_pkghome/lib \
		"$pkgdir"/$_pkghome/GPL* \
		"$pkgdir"/$_pkghome/gdata \
		"$pkgdir"/$_pkghome/autoupdate \
		"$pkgdir"/$_pkghome/fcgi-bin/* \
		"$pkgdir"/$_pkghome/bin/lshttpd \
		"$pkgdir"/$_pkghome/admin/conf/php.* \
		"$pkgdir"/$_pkghome/admin/misc/gdb-bt \
		"$pkgdir"/$_pkghome/admin/misc/convertxml.* \
		"$pkgdir"/$_pkghome/admin/misc/build_admin_php.sh

	# fix ownership
	chown -R $pkgusers:$pkggroups \
		"$pkgdir"/$_pkghome/tmp \
		"$pkgdir"/$_pkghome/conf \
		"$pkgdir"/$_pkghome/logs \
		"$pkgdir"/$_pkghome/backup \
		"$pkgdir"/$_pkghome/cachedata \
		"$pkgdir"/$_pkghome/admin/tmp \
		"$pkgdir"/$_pkghome/admin/logs \
		"$pkgdir"/$_pkghome/admin/conf \
		"$pkgdir"/$_pkghome/admin/cgid \
		"$pkgdir"/$_pkghome/Example/logs

	# install configs
	mv "$pkgdir"/$_pkghome/conf \
		"$pkgdir"/etc/$pkgname
	mv "$pkgdir"/$_pkghome/admin/conf \
		"$pkgdir"/etc/$pkgname/admin
	ln -s /etc/$pkgname "$pkgdir"/$_pkghome/conf
	ln -s /etc/$pkgname/admin "$pkgdir"/$_pkghome/admin/conf
	find "$pkgdir"/etc/$pkgname -type f -print0 | xargs -0 chmod -x

	# install binary
	mv "$pkgdir"/$_pkghome/bin/$_pkgreal \
		"$pkgdir"/usr/sbin/lshttpd
	ln -sf /usr/sbin/lshttpd \
		"$pkgdir"/$_pkghome/bin/$pkgname

	# install modules
	for file in $(find "$pkgdir"/$_pkghome/modules -name "*.so"); do
		mv $file "$pkgdir"/usr/lib/$pkgname/${file##*/}
		ln -s /usr/lib/$pkgname/${file##*/} $file
	done

	# install logs
	mv "$pkgdir"/$_pkghome/logs "$pkgdir"/var/log/$pkgname
	mv "$pkgdir"/$_pkghome/admin/logs "$pkgdir"/var/log/$pkgname/admin
	mv "$pkgdir"/$_pkghome/Example/logs "$pkgdir"/var/log/$pkgname/Example
	ln -s /var/log/$pkgname "$pkgdir"/$_pkghome/logs
	ln -s /var/log/$pkgname/admin "$pkgdir"/$_pkghome/admin/logs
	ln -s /var/log/$pkgname/Example "$pkgdir"/$_pkghome/Example/logs

	# install backend
	ln -s /usr/bin/ls$_php "$pkgdir"/$_pkghome/fcgi-bin/lsphp
	ln -s /etc/$_php/php.ini "$pkgdir"/etc/$pkgname/php.ini
	ln -s /etc/$_php/php.ini "$pkgdir"/etc/$pkgname/admin/php.ini
}

package
