---
layout: post
title: Inside The Search Engine
date: 2015-08-02 14:03:00 +0800
categories: [search]
---

## Table of Contents

* TOC
{:toc}

<!--more-->

## Build Query

### QueryParser

## Search Query

### Models

1. Pure Boolean model
2. Vector space model
3. Probabilistic model

## Index

```
Document -> Analyzer -> IndexWriter -> Directory
```

```
maxDoc() -> count of all docs (including deleted docs)
numDocs() -> count of non-deleted docs
```

## Field

### Index Options

* Index.ANALYZED
* Index.NOT_ANALYZED
* Index.ANALYZED_NO_NORMS
    * norms: index-time boost
* Index.NO

### Store Options

* Store.YES
* Store.NO

Index Option | Store Option | TermVector | Example
:-----------:|:------------:|:----------:|:-------:
NOT_ANALYZED_NO_NORMS | YES | NO         | Identifier (filename, primary key), mobile, phone number, ID
ANALYZED     | YES          | WITH_POSITIONS_OFFSETS | article title, abstract
ANALYZED     | NO           | WITH_POSITIONS_OFFSETS | article body
NO           | YES          | NO         | doctype, db primary key (if not used for search)
NOT_ANALYZED | NO           | NO         | hidden keywords

## Boost

### Document Boost

```java
Document document = new Document();
Author author = Authors.get("oxnz");
document.add(new Field("author", author.getName(), Field.Store.YES, Field.Index.NOT_ANALYZED));
// add other fields ...
if (author.isPopular()) document.setBoost(1.5F);
writer.addDocument(document);
```

### Field Boost

```java
Field subjectField = new Field("subject", subject, Field.Store.YES, Field.Index.ANALYZED);
subjectField.setBoost(1.2F); // a little more important than other fields
```

### Implicit Boost

IndexWriter use Similarity.lengthNorm boost shorter fields

## Norms

norms computed during index time, can be updated via IndexWriter's setNorm.

```
user clicks    --
                |-> setNorm -> dynamic norms (popularity)
recent updates --
```

## Field Truncation

MaxFieldLength:

* MaxFieldLength.UNLIMITED
* MaxFieldLength.LIMITED

## Near-real-time Search

```java
IndexReader.getRead()
```

will flush index buffer, slows down index speed.

## Index Optimization

can speed up search performance, not index.

merge segments

## Index Lock

Use Directory.setLockFactory to override default lock factory.

* NativeFSLockFactory
* SimpleFSLockFactory
* SingleInstanceLockFactory
* NoLockFactory (cautious)

`IndexWriter.isLocked(Directory)`

`IndexWriter.unlock(Directory)`

## Index Debug

```java
IndexWriter writer = new IndexWriter(dir, analyzer, IndexWriter.MaxFieldLength.UNLIMITED);
writer.setInfoStream(System.out);
```

## Advanced

### Delete Docuemnts using IndexReader

IndexReader can

* delete documents by document N.O.
* delete by Term
* instantly
* delete by Query
* `undeleteAll`

### Reclaim disk space used for deleted documents

`expungeDeletes`

### Buffer and Flush

Flush when

* `setRAMBufferSizeMB`
* `setMaxBufferedDocs`
* `setMaxBufferedDeleteTerm`

`IndexWriter.DISABLE_AUTO_FLUSH` can be passed to any of the 3 methods above to prevent auto flush.

### Index Commit

* `commit()`
* `commit(Map<String, String> commitUserData)`
* `rollback()`

TWO-PHASE commit:

* `prepareCommit()` or `prepareCommit(Map<String, String> commitUserData)`
* `commit()` or `rollback()`

`IndexDeletionPolicy`

`IndexReader.listCommits()`

### ACID

simplified ACID, limitation is can only open one transaction(writer) a time.

### Segment Merge

MergePolicy

MergeScheduler

## Search Functionality

### Search a specific Term

```java
Directory dir = FSDirectory.open(new File(System.getProperty("index.dir")));
IndexSearcher searcher = new IndexSearcher(dir);
Term term = new Term("subject", "lucene");
Query query = new TermQuery(term);
TopDocs docs = searcher.search(query, 10);
// process the search results
searcher.close();
dir.close();
```

### QueryParser

```
                           Query Object
Expression -> QueryParser --------------> IndexSearcher
                   ^
                   |
                   v
                Analyzer
```

```java
QueryParser parser = new QueryParser(Version version, String field, Analyzer analyzer);
public Query parse(String query) throws ParseException
```

Expression           | Match
:-------------------:|:------------------:
shell | default field contains shell
shell bash  <br /> shell OR bash | contains either shell or bash or both in the default field
+shell + bash <br /> shell AND bash | contain both shell and bash in the default field
title:bash | contains bash in the title field
title:shell -subject:goods <br> title:shell AND NOT subject:goods | title contains shell and subject does not contains goods
(csh or bash) AND shell | contain shell in the default field and contain either tcsh or bash or both
title:"advanced bash shell guide" | title field is "advanced bash shell guide"
title:"advanced bash shell guide" ~5 | title field within distance 5
c* | contains docs begin with c, like 'cpp', 'cplusplus', 'cc', 'csh', and 'c' itself
shell~ | contains similar to shell, like shill
updated:[1/1/16 TO 12/31/16] | updated field between 1/1/16 and 12/31/16

Note
: need to escape chars: `\ + - ! ( ) : ^ ] { } ~ * ?`

#### Query.toString

```java
query.toString("field");
query.toString();
QueryParser parser = new QueryParser(Version.LUCENE_50, "author", analyzer);
Query query = parser.parse("oxnz");
System.out.println("term: " + query); // term: author:oxnz
```

* FuzzyQuery: `shell~`, `shell~0.8`
* MatchAllDocsQuery: `*:*`

### Create IndexSearch

```java
Directory dir = FSDirectory.open(new File("/path/to/index"));
IndexSearcher searcher = new IndexSearcher(dir);
// or
IndexReader reader = IndexReader.open(dir);
IndexSearcher searcher = new IndexSearcher(reader);
```

```
Query -> IndexSearcher -> TopDocs
               |
               v
          IndexReader
               |
               v
           Directory
               |
               v
             Disk
```

```java
IndexReader newReader = reader.reopen();
if (reader != newReader) {
    reader.close();
    reader = newReader;
    searcher = new IndexSearcher(reader);
}
```

### Search

search method                                     | use situation
:------------------------------------------------:|:---------------:
TopDocs search(Query query, int n)                | direct search, top n docs returned
TopDocs search(Query query, Filter filter, int n) | subset based on filter
TopFieldDocs search(Query query, Filter filter, int n, Sort sort) | custom sort
void search(Query query, Collector collector)     | custom doc access policy
void search(Query query, Filter filter, Collector collector) | filter used

TopDocs methods or properties | return value
:----------:|:------:
totalHits | total doc count matching search condition
scoreDocs | result ScoreDoc object array
getMaxScore() | max score

### Result Pagination

### Score

* store multi-page results in ScoreDocs and IndexSearcher instance, return page when user switch page
* re-search when user switch page

### Near-real-time search

```java
IndexReader reader = writer.getReader();
IndexSearcher searcher = new IndexSearcher(reader);
// updates ...
IndexReader newReader = reader.reopen();
if (reader != newReader) {
    reader.close();
    searcher = new IndexSearcher(newReader);
}
// serve new search requests ...
```

### Score

#### similarity assessment formular

score factor | description
:-----------:|:----------------------------:
tf(t in d)   | term frequency factor
idf(t)       | inverted document frequency
boost(t.field in d) | field and document boost, set during index
lengthNorm(t.field in d) | field normalization value
coord(q, d)  | Coordination factor, based count term in document
queryNorm(q) | sum(squre(term weight))

```
Similarity
   |______ DefaultSimilarity
```

#### explain 

```java
public class Explainer
    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("Usage: Explainer <index dir> <query>");
            System.exit(1);
        }
        String indexPath = args[0];
        String queryExpr = args[1];

        Directory dir = FSDirectory.open(new File(indexPath));
        QueryParser parser = new QueryParser(Version.LUCENE_50, "contents",
            new SimpleAnalyzer());
        Query query = parser.parse(queryExpr);
        System.out.println("Query: " + queryExpr);

        IndexSearcher searcher = new IndexSearcher(dir);
        TopDocs topDocs = searcher.search(query, 10);

        for (ScoreDoc match : topDocs.scoreDocs) {
            Explaination explaination = searcher.explain(query, match.doc);

            System.out.println("-----------");
            Document doc = searcher.doc(match.doc);
            System.out.println(doc.get("title"));
            System.out.println(explaination.toString());
        }
        searcher.close();
        dir.close();
    }
}
```

### Queries

#### TermQuery

```java
Term term = new Term("author", "oxnz");
Query query = new TermQuery(term);
```

#### TermRangeQuery

each Term in index is sorted by dict order (String.compareTo).

```java
TermRangeQuery query = new TermRangeQuery("title", "a", "n", true, true);
```

#### NumericRangeQuery

```java
NumericRangeQuery query = NumericRangeQuery.newIntRange("updated",
    20160723, 20161231, true, true);
```

#### PrefixQuery

```java
Term term = new Term("cat", "/programming/cplusplus/");
PrefixQuery query = new PrefixQuery(term);
```

#### BooleanQuery

public void add(Query query, BooleanClause.Occur occur);

Occur:

* BooleanClause.Occur.MUST
* BooleanClause.Occur.SHOULD
* BooleanClause.Occur.MUST_NOT

```java
BooleanQuery query = new BooleanQuery();
query.add(new TermQuery(new Term("author", "oxnz")), BooleanClause.Occur.MUST);
query.add(NumericRangeQuery.newIntRange("published", 20110901, 20150701,
    true, true), BooleanClause.Occur.MUST);
```

Max Sub Query: 1024

#### PhraseQuery

```java
public boolean matched(String[] phrase, int slop) {
    PhraseQuery query = new PhraseQuery();
    query.setSlop(slop);
    for (String word : phrase) query.add(new Term("field", word));
    TopDocs topDocs = searcher.search(query, 1);
    return topDocs.totalHits > 0;
}
```

score factor:

\frac{1}{distance+1}

#### WildcardQuery

Lucene use two standard wildcard character:

`*`: 0 or more char
`?`: 0 or 1 char

```java
Query query = new WildcardQuery(new Term("shell", "*sh"));
```

Note
: wildcard character have no impact on score

#### FuzzyQuery

Levenshtein (Edit Distance)

score factor:

1-\frac{distance}{min(textlen, targetlen)}

#### MatchAllDocsQuery

```java
Query query = new MatchAllDocsQuery(field);
```

## Analysis

```
       Analysis
Field ----------> Term
```

```
Field -
      |-> Term
Token -
```

lemmatization

When analyze occurs:

* Index
* Query
* Highlight

### Analyzer

* WhitespaceAnalyzer
* SimpleAnalyzer
* StopAnalyzer
* StandardAnalyzer
* SynonymAnalyzer

```java
Analyzer analyzer = new StandardAnalyzer(Version.LUCENE_50);
IndexWriter writer = new IndexWriter(directory, analyzer,
    IndexWriter.MaxFieldLength.UNLIMITED);
Document doc = new Document();
doc.add(new Field("title", title, Field.Score.YES, Field.Index.ANALYZED));
doc.add(new Field("contents", contents, Field.Score.NO, Field.Index.ANALYZED));
writer.addDocument(doc);
```

* `public TokenStream tokenStream(String fieldName, Reader reader)`
* `public TokenStream reusableTokenStream(String fieldName, Reader reader)`
    * optional

```java
public final class SimpleAnalyzer extends Analyzer {
    @Override
    public TokenStream tokenStream(String fieldName, Reader reader) {
        return new LowerCaseTokenizer(reader);
    }

    @Override
    public TokenStream reusableTokenStream(String fieldName, Reader reader)
        throws IOException {
        Tokenizier tokenizer = (Tokenizier) getPreviousTokenStream();
        if (tokenizer == null) {
            tokenizer = new LowerCaseTokenizer(reader);
            setPreviousTokenStream(tokenizer);
        } else tokenizer.reset(reader);
        return tokenizer;
    }
}
```

### TokenStream

* Tokenizer
    * CharTokenizer
        * WhitespaceTokenizer
        * LetterTokenizer
            * LowerCaseTokenizer
    * KeywordTokenizer
    * StandardTokenizer
* TokenFilter
    * LowerCaseFilter
    * StopFilter
    * PorterStemFilter (Porter Stemming Algorithm)
    * TeeSinkTokenFilter
    * ASCIIFoldingFilter
    * CachingTokenFilter
    * LengthFilter
    * StandardFilter

#### Analyzer chain

```
Reader -> Tokenizer -> TokenFilter -> TokenFilter -> ... -> Tokens
```

```java
public TokenStream tokenStream(String fieldName, Reader reader) {
    return new StopFilter(true, new LowerCaseTokenizer(reader), stopWords);
}
```

```java
public static void displayTokens(Analyzer analyzer, String fieldName, String text)
    throws IOException {
    displayTokens(analyzer.tokenStream(fieldName, new StringReader(text)));
}

public static void displayTokens(TokenStream stream) throws IOException {
    TermAttribute termAttr = stream.addAttribute(TermAttribute.class);
    PositionIncrementAttribute posIncrAttr = stream.addAttribute(
        PositionIncrementAttribute.class);
    OffsetAttribute offsetAttr = stream.addAttribute(OffsetAttribute.class);
    TypeAttribute typeAttr = stream.addAttribute(TypeAttribute.class);

    int position = 0;
    while (stream.incrementToken()) {
        int increment = posIncrAttr.getPositionIncrement();
        if (increment > 0) position += increment;
        System.out.println("\n" + position + ": [" +
            termAttr.term() + ": " +
            offsetAttr.startOffset() + "->" + offsetAttr.endOffset() + ":" +
            typeAttr.type() + "] ");
    }
}
```

Lucene unit Attribute

Unit Interface   | Description
:---------------:|:-----------:
TermAttribute    | unit corresponding text
PositionIncrementAttribute | position increment (default: 1)
OffsetAttribute  | start and end offset
TypeAttribute    | unit type (default: word)
FlagsAttribute   | custom flag
PayloadAttribute | byte[] payload

### Metaphone

```java
public class MetaphoneReplacementFilter extends TokenFilter {
    public static final String METAPHONE = "metaphone";
    private Metaphone metaphone = new Metaphone();
    private TermAttribute termAttr;
    private TypeAttribute typeAttr;

    public MetaphoneReplacementFilter(TokenStream stream) {
        super(stream);
        termAttr = addAttribute(TermAttribute.class);
        typeAttr = addAttribute(TypeAttribute.class);
    }

    public boolean incrementToken() throws IOException {
        if (!stream.incrementToken()) return false;
        termAttr.setTermBuffer(metaphone.encode(termAttr.term()));
        typeAttr.setType(METAPHONE);
        return true;
    }
}
```

### SynonymAnalyzer

```java
public class SynonymAnalyzer extends Analyzer {
    private SynonymEngine engine;

    public SynonymAnalyzer(SynonymEngine engine) {
        this.engine = engine;
    }

    public TokenStream tokenStream(String fieldName, Reader reader) {
        TokenStream stream =
            new SynonymFilter(
                new StopFilter(true,
                    new LowerCaseFilter(
                        new StandardFilter(
                            new StandardTokenizer(Version.LUCENE_50, reader))),
                    StopAnalyzer.ENGLISH_STOP_WORDS_SET),
                engine);
        return stream;
    }
}
```

### SynonymFilter

```java
public class SynonymFilter extends TokenFilter {
    public static final String TOKEN_TYPE_SYNONYM = "SYNONYM";
    private Stack<String> synonymStack;
    private SynonymEngine synonymEngine;
    private AttributeSource.State attrState;
    private final TermAttribute termAttr;
    private final PositionIncrementAttribute posIncrAttr;

    public SynonymFilter(TokenStream stream, SynonymEngine synonymEngine) {
        super(stream);
        synonymStack = new Stack<String>();
        this.synonymEngine = synonymEngine;
        this.termAttr = addAttribute(TermAttribute.class);
        this.posIncrAttr = addAttribute(PositionIncrementAttribute.class);
    }

    public boolean incrementToken() throws IOException {
        if (synonymStack.size() > 0) {
            String synonym = synonymStack.pop();
            restoreState(attrState);
            termAttr.setTermBuffer(synonym);
            posIncrAttr.setPositionIncrement(0);
            return true;
        }

        if (!stream.incrementToken()) return false;
        if (addAliasesToStack()) attrState = captureState();
    }

    private boolean addAliasesToStack() throws IOException {
        String[] synonyms = synonymEngine.getSynonyms(termAttr.term());
        if (synonyms == null) return false;
        for (String synonym : synonyms) synonymStack.push(synonym);
        return true;
    }
}
```

### ShingleFilter

### Field Analysis

#### Multi-value Field

Override `getPositionIncrementGap` to return non-zero to indicate gap.

#### Specific Field Analysis

```java
PerFieldAnalyzerWrapper analyzer = new PerFieldAnalyzerWrapper(new SimpleAnalyzer());
analyzer.addAnalyzer("title", new StandardAnalyzer(Version.LUCENE_50));
analyzer.addAnalyzer("author", new KeywordAnalyzer());
// search not analyzed
Query query = new QueryParser(Version.LUCENE_50, "title", analyzer).parse(
    "author:oxnz AND lucene");
assertEquals("+author:oxnz +lucene", query.toString("title"));
```

### Language Analysis

http://www.joelonsoftware.com/articles/Unicode.html

#### Char Normalization

```
Reader -> CharReader -> CharFilter -> CharFilter -> Tokenizer ->
TokenFilter -> TokenFilter -> Tokens
```

#### CJK Support

* CJKAnalyzer
* ChineseAnalyzer
* SmartChineseAnalyzer

### Nutch

```java
public class NutchExt {
    public static void main(String[] args) throws IOException {
        Configuration config = new Configuration();
        config.addResource("nutch-ext.xml");
        NutchDocumentAnalyzer analyzer = new NutchDocumentAnalyzer(config);

        TokenStream ts = analyzer.tokenStream("content",
            new StringReader("The quick brown fox ..."));

        int position = 0;
        while (true) {
            Token token = ts.next();
            if (token == null) break;
            int increment = token.getPositionIncrement();
            if (increment > 0) position += increment;
            System.out.println("\n" + position + ": [" +
                token.termText() + ":" + token.startOffset() + "->" +
                token.endOffset() + ":" + token.type() + "]");
        }

        Query nutchQuery = Query.parse("\"the quick brown\"", config);
        org.apache.lucene.search.Query luceneQuery = 
            new QueryFilters(config).filter(nutchQuery);
        System.out.println("lucene Q: " + luceneQuery);
    }
}
```

## Advacend Search

### Field Cache

Lucene field cache is an advanced internal API, its purpose is to satisfy the need to fast access some field value of docs.
Field cache is invisible to users, but it's important for some advanced function, such as sort by field value, background caching, etc.

#### Load Field Cache for all docs

The field cache use fieldName and reader as Key.

```java
int[] update_timestamps = FieldCache.DEFAULT.getIntegers(reader, "updated");
int updated = update_timestamps[docID];
```

#### Field corresponding reader

avoid pass top level reader to field cache API.

### Sorting

#### Sort by field value

IndexSearcher setDefaultFieldSortScoring()

* doTranceScores
* doMaxScore

#### Sort by relevance

This is the default score method.

Sort.RELEVANCE

#### Sort by index order

Sort.INDEXORDER

#### Sort by field

This demands the field is indexed as a whole, i.e. Index.NOT_ANALYZED or Index.NOT_ANALYZED_NO_NORMS.

`new SortField("title", SortField.STRING)`

#### Sort by multi field

```java
new Sort(
    new SortField("title", SortField.STRING),
    SortField.FIELD_SCORE,
    new SortField("updated", SortField.INT, true));
```

* SortField.SCORE (relevance)
* SortField.DOC (doc ID)
* SortField.STRING (String.compareTo())
* SortField.BYTE
* SortField.SHORT
* SortField.INT
* SortField.LONG
* SortField.FLOAT
* SortField.DOUBLE

#### Sort Locale

SortField.STRING

```java
public SortField(String field, Locale locale)
public SortField(String field, Locale locale, boolean reverse)
```

### MultiPhraseQuery

```java
MultiPhraseQuery query = new MultiPhraseQuery();
query.add(new Term[] {
    new Term("field", "quick"),
    new Term("field", "fast")
});
query.add(new Term("field", "fox"));
```

### Search Multi Field

* Create a all-in-one field contains all field
    * good performance
    * index the same text twice
    * cannot boost single field
* Use MultiFieldQueryParser
* DisjunctionMaxQuery

### SpanQuery

position-aware search

cpu-bound query

* SpanTermQuery
* SpanFirstQuery
* SpanNearQuery
* SpanNotQuery
* FieldMaskingSpanQuery
* SpanOrQuery

### Filtering

search-within-search

* TermRangeFilter
* NumericRangeFilter
* FieldCacheRangeFilter
* FieldCacheTermsFilter
* QueryWrapperFilter
* SpanQueryFilter
* PrefixFilter
* CachingWrapperFilter
* CachingSpanFilter
* FilteredDocIdSet

#### TermRangeFilter

like TermRangeQuery without scorer. used against text field. use NumericRangeFilter for numeric field instead.

#### FieldCacheRangeFilter

```java
Filter filter = FieldCacheRangeFilter.newIntRange("updated",
    20161123, 20161231, true, true);
```

#### Term Filter

* FieldCacheTermsFilter (caching)
* TermsFilter (no caching)

#### QueryWrapperFilter

```java
TermQuery query = new TermQuery(new Term("type", "article"));
Filter filter = new QueryWrapperFilter(query);
```

#### SpanQueryFilter

```java
SpanQuery query = new SpanTermQuery(new Term("type", "article"));
Filter filter = new SpanQueryFilter(query);
```

#### SecurityFilter

#### Cache filtered results

CachingWrapperFilter use a WeakHashMap internally to manage cache, and can be used to cache any filter results.

#### Encapsulate filter into query

query can be encapsulated into filter, and can do it inversely.

ConstantScoreQuery

#### FilteredDocIdSet

#### Non-builtin filter

contrib.ChainedFilter

### Function Queries

```java
Query q = new QueryParser(Version.LUCENE_50, "title",
    new StandardAnalyzer(Version.LUCENE_50)).parse("black and red");
FieldScoreQuery qf = new FieldScoreQuery("score", FieldScoreQuery.Type.BYTE);
CustomScoreQuery customQ = new CustomScoreQuery(q, qf) {
    public CustomScoreProvider getCustomScoreProvider(IndexReader reader) {
        return new CustomScoreProvider(reader) {
            public float customScore(int doc, float subQueryScore, float valueSourceScore)
            {
                return (float) (Math.sqrt(subQueryScore) * valueSourceScore);
            }
        };
    }
};
```

#### Freshness Boost

```java
static class FreshnessBoostQuery extends CustomScoreQuery {
    double multiplier;
    int today;
    int maxDaysAgo;
    String dayField;
    static int MSEC_PER_DAY = 1000*3600*24;

    public FreshnessBoostQuery(Query q, double multiplier, int maxDaysAgo, String dayField) {
        super(q);
        today = (int) (new Date().getTime()/MSEC_PER_DAY);
        this.multiplier = multiplier;
        this.maxDaysAgo = maxDaysAgo;
        this.dayField = dayField;
    }

    private class FreshnessScoreProvider extends CustomScoreProvider {
        final int[] updated;

        public FreshnessScoreProvider(IndexReader reader) throws IOException {
            super(reader);
            updated = FieldCache.DEFAULT.getInts(reader, dayField);
        }

        public float customScore(int doc, float subQueryScore, float valueSourceScore)
        {
            int daysAgo = today - updated[doc];
            if (daysAgo < maxDaysAgo) {
                float boost = (float) (multiplier * (maxDaysAgo - daysAgo)
                    / maxDaysAgo);
                return (float) (subQueryScore * (1.0 + boost));
            } else return subQueryScore;
        }
    }

    public CustomScoreProvider getCustomScoreProvider(IndexReader reader)
        throws IOException { return new FreshnessScoreProvider(reader); }
}
```

Usage:

```java
Query origQ = parser.parse("red and black");
Query freshnessQ = new FreshnessBoostQuery(origQ, 2.0, 2*365);
Sort sort = new Sort(new SortField[] {
    SortField.FIELD_SCORE,
    new SortField("title", SortField.STRING)});
TopDocs hits = searcher.search(freshnessQ, null, 5, sort);
```

### Search against multiple indexes

* MultiSearcher (single-thread)
* ParallelMultiSearcher (multi-thread)

```java
MultiSearcher searcher = new MultiSearcher(new IndexSearcher[] {
    new IndexSearcher(directoryA), new IndexSearcher(directoryB)});
```

ParallelMultiSearcher has the same API as MultiSearcher.

### Term Vector

term vector is consist of a group of term-frequency pair.

```java
TermFreqVector termFreqV = reader.getTermFreqVector(id, "title");
```

Field.TermVector.WITH_POSITION_OFFSETS

### FieldSelector

FieldSelectorResult accept(String fieldName);

Option | Description
LOAD | Load
LAZY_LOAD | Lazy load, load when `Field.stringValue()` or `Field.binaryValue()`
NO_LOAD | skip load
LOAD_AND_BREAK | after loading this field, stop loading other field
LOAD_FOR_MERGE | internal used for segment merge
SIZE | only read field length, and encode into a 4 byte array as a new binary field
SIZE_AND_BREAK | like SIZE, but don not load any field left

### Abort slow query

TimeLimitingCollector

TimeExceededException

```java
Collector collector = new TimeLimitingCollector(topDocs, 1000);
try {
    searcher.search(q, collector);
} catch (TimeExceededException e) {
    System.out.println("timeout");
}
```

## Extending Search

### Custom Sorting

via subclassing `FieldComparatorSource`.

```java
public class DistanceComparatorSource extends FieldComparatorSource {
    private int x;
    private int y;

    public DistanceComparatorSource(int x, int y) { this.x = x; this.y = y; }

    public FieldComparator newComparator(String fieldName, int nHits,
        int sortPos, boolean reversed) throws IOException {
        return new DistanceComparator(fieldName, nHits);
    }

    private class DistanceComparator extends FieldComparator {
        private int[] x;
        private int[] y;
        private float[] values;
        private float bottom;
        String fieldName;

        public DistanceComparator(String fieldName, int nHits) throws IOException {
            values = new float[nHits];
            this.fieldName = fieldName;
        }

        public void setNextReader(IndexReader reader, int docBase) throws IOException {
            x = FieldCache.DEFAULT.getInts(reader, "x");
            y = FieldCache.DEFAULT.getInts(reader, "y");
        }

        private float getDistance(int doc) {
            int deltaX = x[doc] - x;
            int deltaY = y[doc] - y;
            return (float) Math.sqrt(deltaX * deltaX + deltaY * deltaY);
        }

        public int compare(int slot1, int slot2) {
            if (values[slot1] < values[slot2]) return -1;
            if (values[slot1] > values[slot2]) return 1;
            return 0;
        }

        public void setBottom(int slot) { bottom = values[slot]; }

        public int compareBottom(int doc) {
            float dist = getDistance(doc);
            if (bottom < dist) return -1;
            if (bottom > dist) return 1;
            return 0;
        }

        public void copy(int slot, int doc) { values[slot] = getDistance[doc]; }

        public Comparable value(int slot) { return new Float(values[slot]); }

        public int sortType() { return SortField.CUSTOM; }
    }

    public String toString() { return "Distance from (" + x + ", " + y + ")"; }
}
```

### Custom Collector

* setNextReader(IndexReader reader, int docBase)
* setScorer(Scorer scorer)
* collect(int docID)
* acceptsDocsOutOfOrder()

### Extend QueryParser

Method | Description
getFieldQuery(String field, Analyzer analyzer, String queryText) <br> getFieldQuery(String field, Analyzer analyzer, String queryText, int slop) | construct TermQuery or PhraseQuery
getFuzzyQuery(String field, String termStr, float minSimilarity) | FuzzyQuery
getPrefixQuery(String field, String termStr) | pass
getRangeQuery(String field, String start, String end, boolean inclusive) | transform range representation
getBooleanQuery(List clauses) <br> getBooleanQuery(List clauses, boolean disableCoord) | BooleanQuery
getWildcardQuery(String field, String termStr) | raise ParseException to disable wildcard query

```java
public class CustomQueryParser extends QueryParser {
    public CustomQueryParser(Version matchVersion, String field, Analyzer analyzer) {
        super(matchVersion, field, analyzer);
    }

    protected final Query getWildcardQuery(String field, String termStr)
    throws ParseException {
        throw new ParseException("wildcard not allowed");
    }

    protected Query getFuzzyQuery(String field, String term, float minSimilarity)
    throws ParseException {
        throw new ParseException("fuzzy queries not allowed");
    }
}
```

### Custom Filter

#### FilteredQuery

```java
Query query = new TermQuery(new Field("category", "sysadm"));
Filter filter = FieldCacheRangeFilter.newIntRange("updated",
    20161123, 20161231, true, true);
FilteredQuery Q = new FilteredQuery(query, filter);
```

### Payloads

Name | Desc
:---:|:----:
NumericPayloadTokenFilter     | encoded into float payload
TypeAsPayloadTokenFilter      | type as payload
TokenOffsetPayloadTokenFilter | offset (start, end) -> payload
PayloadHelper                 | static method. {int,float} <-> byte[] payload

#### TermPositions

* boolean isPayloadAvailable()
* int getPayloadLength()
* byte[] getPayload(byte[] data, int offset)

## Essential Lucene Extensions

### Luke (the Lucene Index Toolbox)

### Analyzers, Tokenizers and TokenFilters

* Ngram Filters
* Shingle Filters

### Highlighting

TermVector.WITH_POSITION_OFFSETS

TermVectors gives the best performance, but consume additional space in the index.

Highlighter relies on the start and end offset of each token from the token stream to locate the exact character slices to highlight in the original input text.

Fragmenter
: split the original string into separate fragments for consideration.

* NullFragmenter
    * returns the entire string as a single fragment, appropriate for title fields and other short text fields
* SimpleFragmenter
    * break up the text into fixed-size fragments by character length, with no effort to spot sentence boudaries
    * doesn't take into account positional constraints of the query when creating fragments, which means for phrase queries and span queries, a matching span will easily be broken accross two fragments
* SimpleSpanFragmenter
    * resolves above problem by attempting to make fragments that always include the spans matching each document

Scorer
: help highlighter pick out the best one(s) of fragments to present by score each fragment

* QueryTermScorer
* QueryScorer

Encoder
: encode the original text into the external format

* DefaultEncoder (do nothing)
* SimpleHTMLEncoder (escape `< > &`)

Formatter
: render the highlighting

* SimpleHTMLFormatter (`<b>`)
* GradientFormatter (`<font>`)
* SpanGradientFormatter (`<span>`)

```
Text      Term Vectors
 |             |
 -------v-------
        |
   TokenSources
        |
        v
   Fragmenter -> Scorer -> Encoder -> Formatter -> Highlighted Text
```

```java
String text = "The quick brown fox jumps over the lazy dog";
TermQuery query = new TermQuery(new Term("content", "fox"));
TokenStream tokenStream = new SimpleAnalyzer().tokenStream("content",
    new StringReader(text));
QueryScorer scorer = new QueryScorer(query, "content");
Fragmenter fragmenter = new SimpleSpanFragmenter(scorer);
Hgihlighter highlighter = new Highlighter(scorer);
highlighter.setTextFragmenter(fragmenter);
assertEquals("The quick brown <B>fox</B> jumps over the lazy dog",
    highlighter.getBestFragment(tokenStream, text));
```

### Spell Correction

#### Generating suggestion list

It's hard to determine whether the spell checking is needed up front, so just run the spell checking and then use the score of each potential suggestion to decide whether the suggestions should be presented to the user.

spell checker works with one term at a time, but would be nice if it would work with multiple terms.

The naive way is to use an accurate dictionary, but it is hard to keep up to date and match the search domain.
A better way would be deriving a dictionary by use the search index to gather all unique terms seen during indexing from a particular field.
Given the dictionary, it's necessary to enumerate the suggestions. There are several ways to do it:

* use a phonetic approach (sounds like)
* use letter ngrams to identify similar words
    * the ngrams for all words in the dictionary are indexed into a separate spellchecking index
    * the spellchecking index is rebuilt when the main index is updated
    * the correct word will be returned with a high score because it shares many of the ngrams with the mispelled ones
    * the relevance ranking is generally not good for selecting the best one
    * typically, a different distance metric is used to resort the suggestions according to how similar each is to the original term, one common metric is the Levenshtein metric

Some improvment hints:

* consider using the terms from user's queries to help rank the best suggestion
* compute term co-occurrence statistics up front
* filter out bad terms
* only accept terms that occurred above a certain frequency
* train the spell checker according to click statistics for 'Did you mean ...'
* avoid information leaking (if the search application has entitlements)
* tweak the method how to compute the confidence of each suggestion
* search twice, first with the original search, to see if it matches too less documents, search a second time with the corrected spell if yes

### Other Query Extensions

* MoreLikeThis
* FuzzyLikeThisQuery
* BoostingQuery
* TermsFilter
* DuplicateFilter
* RegexQuery

## Futher Lucene Extensions

This chapter covers

* Searching indexes remotely using RMI
* Chaining multiple filters into one
* Storing an index in Berkeley DB
* Storing and filtering according to geographic distance

### Chaining filters

`ChainedFilter` lets you logically chain multiple filters together into one `Filter`.

### Storing an index in Berkeley DB

The Berkely DB package enables storing a Lucene index within a Berkeley database.

### Synonyms from WordNet

### Fast memory-based indices

There are two options for storing an index entirely in memory, which provide far faster search performance than RAMDirectory.

### XML QueryParser: Beyond "one box"

### Surround query language

### Spatial Lucene

Spatial Lucene enables sorting and filtering based on geographic distance.

### Searching multiple indexes remotely

You can perform remote searching (over RMI) using the contrib/remote module.

### Flexible QueryParser

### Odds and ends

### Summary

## Lucene administration and performance tuning

### Performance tuning

* index-to-search delay
* indexing throughput
* search latency
* search throughput

#### First step

* SSD
* upgrade lucene, elasticsearch, jvm
* jvm --server
* local filesystem
* java profiler
* Do not reopen IndexWriter/IndexReader/IndexSearcer more frequently that required
* multi-thread
* faster hardware
* resonable memory
* enough mem, CPU, and file descriptors for peak usage
* turn off not used features
* group multiple text fields into a single text field

contrib/benchmark

#### Tips

* warm up newly merged segments before making them available for searching by calling IndexWriter.setMergedSegmentWarmer
* Try switching IndexWriter to the BalancedMergePolicy, to minimize very large segment merges
* try decrease IndexWriter's maxBufferedDocs
    * reduce net indexing rate
    * reduce reopen time
* use AddDocument instead of updateDocument if appropriate

#### Tuning for Indexing throughput

* EnwikiContentSource
* DirContentSource

subclassing ContentSource

WriteLineDoc

```
analyzer=org.apache.lucene.analysis.standard.StandardAnalyzer
content.source=org.apache.lucene.benchmark.byTask.feeds.LineDocSource
directory=FSDirectory

doc.stored = true
doc.term.vectors = true
docs.file = /path/to/line/file.txt

{ "Rounds"
    ResetSystemErase
    { "BuildIndex"
        -CreateIndex
    { "AddDocs" AddDoc > : 200000
        -CloseIndex
    }
    NewRound
} : 3

RepSumByPreRound BuildIndex
```

Tips

* multi-thread
* set IndexWriter to flush by memory usage and not document count
    * change from setMaxBufferedDocs to setRAMBufferSizeMB
    * typically larger is better
* turn off compund file format (INdexWriter.setUseCompundFile(false))
    * Elasticsearch
        * compund_format: false
        * compund_on_flush: false
* reuse Document and Field instances
    * change only the Field values, and then call addDocument with the same Document instance
    * the DocMaker is already doing this, turn it off by: doc.reuse.fields = false
* test different values of mergeFactor
    * higher values mean less merging cost while indexing, but slower searching because the index will generally have more segments
* use optimize sparingly, use optimize(maxNumSegments) method instead
* index into separate indices, perhaps using different computers, and then merge them with IndexWirter.addIndexesNoOptimize
* test the speed of creating the documents and tokenizing them by using the ReadTokens task

#### Tuning for search latency and throughput

* NIOFSDirectory
* MMapDirectory
* Add more threads until the throughput no long improves
* warmup before real search requests arrive
* use FieldCache instead of stored fields
* decrease mergeFactor so there are fewer segments in the index
* turn off compound file format
* limit using of term vectors
    * retrieving term vectors is quite slow
    * use TermVectorMapper select the term vectors only needed
* if load stored fields is a must, use FieldSelector to restrict fields to exactly those actually needed
* run optimize or optimize(maxNumSegments) periodically on the indexes
* request as many hits as needed
* inspect query by calling query.rewrite().toString()
* limit FuzzyQuery

### Threads and concurrency

Hard drives now provide native command queuing, which accepts many I/O requests at once and reorders them to make more efficient use of the disk heads. Even solid state disks do the same, and go further by using multiple channels to concurrently access the raw flash storage. The interface to RAM uses multiple channels.

### Managing resource comsumption

#### Disk space

* Open readers prevent deletino of the segment files they're using.
* All segments that existed when the IndexWriter was first opended will remain in the directory, as well as those referenced by the current (in memory) commit point.
* If frequently replace documents but don't run optimze, the space used by old copies of the deleted documents won't be reclaimed until those segments are merged
* The more segments in index, the more disk space will be used - more that if those segments were merged. This means a high mergeFactor will result in more disk space being used
* Given the same net amount of text, many small documents will result in larger index than fewer large documents
* Don't open a new reader while optimize, or any other merges, are running
* Do open a new reader after making changes with IndexWriter, and close the old one.
* If running a hot backup, the files in the snapshot being copied will also comsume disk space until the backup completes and you release the snapshot

## References

* [推荐引擎初探](https://www.ibm.com/developerworks/cn/web/1103_zhaoct_recommstudy1/)
