import dystopia
import qgram

indexer = dystopia.Indexer("test.idx")
q_indexer = qgram.Indexer("q_test.idx")

docs = enumerate(("food", "tasty food", "lawyers", "tasty"))

for doc_id, doc in docs:
	indexer.add_doc(doc_id, doc)
	q_indexer.add_doc(doc_id, doc)

print indexer.get_doc(0)
print indexer.get_doc(doc_id + 1)

indexer.close()
q_indexer.close()

searcher = dystopia.Searcher("test.idx")
q_searcher = qgram.Searcher("q_test.idx")

queries = ("food", "law", "tasty", "tasty food", "tasty || law")

for query in queries:
	print "%s: %s" % (query, searcher.search(query))
	print "%s: %s" % (query, q_searcher.search(query))
