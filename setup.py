from distutils.core import setup
from distutils.extension import Extension

from Cython.Distutils import build_ext

setup(cmdclass = {'build_ext': build_ext},
	  ext_modules = [Extension("dystopia",
							   ["dystopia.pyx"],
							   include_dirs = ['/usr/local/include'],
							   libraries = ['tokyodystopia', 'tokyocabinet',
											'z', 'bz2', 'pthread', 'm', 'c'],
							   library_dirs = ['/usr/local/lib'])])
