Basics
======

Braindead simple api to a tokyo dystopia text index. See test.py for an example, or, for the impatient, use like this:

`import dystopia

indexer = dystopia.Indexer("test.idx")
indexer.add_doc(1, "some test document text")
indexer.close()

searcher = dystopia.Searcher("test.idx")
print searcher.search("text") # => (1, "some test document text")`

Building
========

Install tokyo cabinet & tokyo dystopia (http://tokyocabinet.sf.net), and modify setup.py to point to the correct directory (defaults to /usr/local/lib).

Build like: `python setup.py build_ext --inplace`


