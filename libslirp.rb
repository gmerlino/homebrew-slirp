class Libslirp < Formula
  desc "TCP-IP emulator as a library"
  homepage "https://github.com/rd235/libslirp"

  head do
    url "https://github.com/rd235/libslirp.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
    depends_on "pkg-config" => :build
  end

  patch :DATA

  def install
    system "autoreconf", "-fiv"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
    (lib/"pkgconfig").install "slirp.pc"
  end

  # to be fixed
  test do
    system "true"
  end
end

__END__
diff --git a/configure.ac b/configure.ac
index d3b7c32..5c5893a 100644
--- a/configure.ac
+++ b/configure.ac
@@ -41,6 +41,14 @@ AC_FUNC_MALLOC
 AC_FUNC_REALLOC
 AC_CHECK_FUNCS([atexit clock_gettime dup2 inet_ntoa memmove memset strcasecmp strchr strdup strerror strstr])
 
+AC_CHECK_PROG(PKG_CONFIG, pkg-config, yes)
+if test "x$PKG_CONFIG" != "x"; then
+    HAVE_PKG_CONFIG=1
+    AC_CONFIG_FILES([slirp.pc])
+else
+    HAVE_PKG_CONFIG=0
+fi
+AC_SUBST(HAVE_PKG_CONFIG)
 AC_CONFIG_FILES(
 		[Makefile]
 		[src/Makefile]
diff --git a/slirp.pc.in b/slirp.pc.in
new file mode 100644
index 0000000..569e7bc
--- /dev/null
+++ b/slirp.pc.in
@@ -0,0 +1,11 @@
+prefix=@prefix@
+exec_prefix=@prefix@
+libdir=@libdir@
+includedir=@includedir@
+
+Name: @PACKAGE_NAME@
+Version: @PACKAGE_VERSION@
+Description: SLIRP library, for userspace TCP/IP emulation
+
+Libs: -L${libdir} -lslirp @LIBS@
+Cflags: -I${includedir}
diff --git a/src/libslirp.c b/src/libslirp.c
index da025d4..21e0041 100644
--- a/src/libslirp.c
+++ b/src/libslirp.c
@@ -67,6 +67,10 @@ struct slirp_conn {
 #define SLIRP_DEL_UNIXFWD 0x22
 #define SLIRP_ADD_EXEC 0x31
 
+#ifndef SOCK_CLOEXEC
+#define SOCK_CLOEXEC    02000000
+#endif
+
 struct slirp_request {
 	int tag;
 	int pipefd[2];
