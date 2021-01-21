# mk4rb - ruby bindings to [Metakit](https://www.equi4.com/metakit/).

Bindings are bundled as a ruby gem and consist of c++-extension and
more higher-level ruby code that adds some useful methods, like
idiomatic autoclosing for Storage.open.

Low-level extension code is in ext/metakit_raw directory.
Higher-level ruby code is in lib/mk4rb.rb.

The code is covered by the entire regression test suite of metakit
ported from c++ to utilize mk4rb. This essentially means that as long
as metakit compiles and runs on some platform, so will mk4rb (provided
that ruby compiles and runs on that platform of course).

I've tested mk4rb on the following platforms:
 - gentoo 2004.0 (kernel 2.4.25, libc 2.3.2, gcc 3.3.2)
 - gentoo 2007.0 (kernel 2.6.19, libc 2.5, gcc 4.2)
 - winxp (vs2005)

I used the latest metakit (metakit-2.4.9.7) and ruby (1.8.6) sources to
build both on windows and linux.

I include src directory containing all the sources for c++-extension,
unit tests, example programs and a Rakefile which allows to build the
extension,
run tests and package everything as a gem.

I also include prepackaged gem file which I tested to install
successfully on all of my three testing platforms.

How you can make sure that it works:
 - running 'rake' in src directory will try to compile extension and run
 all the tests - that is known to work.
 - you can then create a gem file (which I already provide) by running
 'rake package'
 - gem install mk4rb-0.1.gem will install the gem (compiling the
 extension along the way)
 - after that you can run any script from 'examples' directory

# License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

Portions of this repo include code copied from or ported from the [Metakit source code](https://git.jeelabs.org/jcw/metakit) which is licensed under the terms of the MIT License.
