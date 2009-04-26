import dystopia

indexer = dystopia.Indexer("test.idx")

docs = enumerate(("food", "tasty food", "lawyers", "tasty"))

for doc_id, doc in docs:
	indexer.add_doc(doc_id, doc)

print indexer.get_doc(0)
print indexer.get_doc(doc_id + 1)

indexer.close()

searcher = dystopia.Searcher("test.idx")
queries = ("food", "law", "tasty", "tasty food", "tasty || law")

for query in queries:
	print "%s: %s" % (query, searcher.search(query))
