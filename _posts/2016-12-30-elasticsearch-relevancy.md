---
title: Elasticsearch - Relevancy
categories: IR
---

<script src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>

之所以相关性比较困难，是因为搜索是一个严重的信息不对等的用户交互过程，所有的交互基本就限定在一个搜索框中，用户提供的搜索词也就寥寥几个，而搜索的数据往往是海量的，包括各种各样的类型和质量，用户的预期却是返回相关性非递增的搜索结果排序展示。

其中为了增加搜索的准确性，可以使用一些上下文信息来帮助搜索引擎。
例如用户搜索时候所在的页面，用户的偏好设置（语言，地理位置），以及累计的用户历史记录等等。

还有一些特定领域的方法，例如具有时效性的新闻，媒体类。

搜索结果的相关性不仅为用户提供了方便，还在潜移默化的影响着用户，甚至可以起到引导用户的作用，比如推荐内容。

## Table of Contents

* TOC
{:toc}

<!--more-->

## Effectiveness

how well does the system satisfy the user's information need?

* algorithm
* interaction
* evaluation

### Algorithms

* term importance (wordrank)
: which words are important when ranking a document (e.g. frequent vs. discriminative words)
* stemming
: how to collapse words which are morphologically equivalent (e.g. bicycles -> bicycle)
* query expansion (synonym)
: how to collapse words which are semantically equivalent (e.g. bicycles -> bicycle)
* document structure
: do matches in different parts of the document matter (e.g. title vs. body match)?
* personalization
: can we exploit user information to improve ranking?
* relevance feedback
: ask a user which documents are relevant
* disambiguation
: how to ask a user which words are important

### Evaluation

* relevance
: how to define a good document
* metrics
: how to measure if the ranking is good
* comparison
: how to compare two systems

## Efficiency

how efficiently does the system satisfy the user's information need?

* indexing architectures
* fast score computation
* evaluation

### Indexing architectures

* parsing
: how should a document be split into a set of terms?
* indexing
: which words should be kept?
* weighting
: what information needs to be stored with terms?
* compression
: how to compress the index size

### Fast score computation

* inverted indices
: fast retrieval and scoring of short queries
* tiering
: can we tier retrieval and ranking to improve performance?
* branch and bound
: how to efficiently prevent scoring unnecessary documents?

## Modeling

information retrieval often involes formally modeling the retrieval process in order to optimize performance.

### Modeling tasks

* abstractly represent the documents
* abstractly represent the queries
* model the relationship between query and document representations

### Boolean Retrieval Model

* represent each document as an unweighted bag of words
* represent the query as an unweighted bag of words
* retrieva an unordered set of documents containing the query words

### Simple Ranked Retrieval Model

* represent each document as an weighted bag of words (based on document frequency)
* represent the query as an unweighted bag of words
* retrieve a ranking documents containing the query words

### Modeling

* much of the history of information retrieval effectiveness research involes developing new models or extending existing models
* as modeling becomes more complicated, mathematics and statistics become necessary
* new models still being developed

### Vector Space Model

* represent each document as a vector in a very high dimensional space
* represent each query as a vector in the same high dimensional space
* rank documents according to some vector similarity measure

#### Fundamentals

* vector componenets
: what does each dimension represent?
* text abstraction
: how to embed a query, document into this space?
* vector similarity
: how to compare documents in this space?

#### Vector Componenets

* Documents and queries should be represented as lineary independent basis vectors
	* Orthogonal 'concepts' such as topics or genres: ideal but difficult to define
	* Controlled keyword vocabulary: flexible and compact but difficult to maintain, may not be linearly independent
	* Free text vocabulary: easy to generate but grows quickly, definitely not linearly independent
* In mose cases, when someone refers to the vector space model, each component of a vector represents the presence of a unique term in the entire corpus

#### Text Abstraction - Documents

* Parse document in a vector of normalized strings
	* words are split on white space, removing punctuation (e.g. 'Cants are lazy.' -> ['Cats', 'are', 'lazy'])
	* words are down-cased (e.g. -> ['cats', 'are', 'lazy'])
	* stop words are removed (e.g. -> ['cats', 'lazy'])
	* words are stemmed (e.g. -> ['cat', 'lazy'])
* Weight each word present in the document
	* Count the frequency of each word in the document (e.g. -> [<'cat', 25>, <'lazy', 25>, <'kitten', 10>, ...])
	* Re-weight according to each word's discriminatory power; Very dependent on corpus
		* corpus about lazy animals:
			* [<'cat', 189.70>, <'lazy', 4.50>, <'kitten', 120.31>, ...]
		* corpus about cats:
			* [<'cat', 0.12>, <'lazy', 54.44>, <'kitten', 5.43>, ...]
	* Alternatively, can use binary weights (e.g. -> [<'cat', 1>, <'lazy', 1>, <'kitten', 1>, <'dog', 0>, ...])

#### Text Discrimination Weights

* Terms which appear in all or very many documents in the corpus may not be useful for indexing or retrieval
* Stop words or 'linguistic glue' can be safely detected using corpus-independent lists
* Other frequent terms may be domain-specific and are detected using corpus statistics
* Inverse document frequency (IDF) summarizes this. For a corpus of n documents, the IDF of term t is defined as

$$IDF_t = 1 + log_2\frac{n}{df_t}$$

where df_t is the document frequency of t

#### Text Abstraction - Queries

* Queries are processed using the exact same process
* Because queries are treated as 'short documents', we can support keyword or document-length query-by-example style queries
* Can be easily generalized to non-english languages

#### Vector Similarity

similarity | binary | weighted
-----------|--------|----------
inner product | $$X \cap Y$$ | $$\sum_ix_iy_i$$
Dice coefficient | $$2\frac{\vert X \cap Y \vert}{\vert X \vert+\vert Y \vert}$$ | $$2\frac{\sum_i{x_iy_i}}{\sum_i{x_i}+\sum_i{y_i}}$$
Cosine coefficient | $$\frac{\vert X \cap Y \vert}{\sqrt{\vert X \vert}\sqrt{\vert Y \vert}}$$ | $$\frac{\sum_i{x_iy_i}}{\sqrt{\sum_ix_i^2}\sqrt{\sum_iy_i^2}}$$
Jaccard coefficient | $$\frac{\vert X \cap Y \vert}{\vert X \vert + \vert Y \vert - \vert X \cap Y \vert}$$ | $$\frac{\sum_ix_iy_i}{\sum_ix_i^2+\sum_iy_i^2-\sum_ix_iy_i}$$

#### Vector Space Model - Efficiency

* precompute length-normalized document vectors
	$$\frac{\sum_ix_iy_i}{\sqrt{\sum_ix_i^2}\sqrt{\sum_iy_i^2}} = \sum_i\frac{x_i}{\sqrt{\sum_ix_i^2}}\frac{y_i}{\sqrt{\sum_iy_i^2}} = \sum_i{x_i^~y_i^\~}$$
* branch and bound to avoid scoring unnecessary documents
* locality sensitive hashing can be used to do very fast approximate search (Indyk an Motwani 1998)

#### Latent Semantic Indexing

(Deerwester et al. 1990)

* Vector space model suffers when there is a query term mismatch (e.g. 'bike' instead of 'bicycle')
* By-product of not having independent basis vectors
* Latent semantic indexing (LSI) attempts to resolve issues with correlated basis vectors
	* Use singular value decomposition (SVD) to find orthogonal basis vectors in the corpus
	* Project documents (and queries) into the lower dimensional 'concept space'
	* Index and retrieve lower dimensional documents as with the classic vector space model
* Similar to clustering documents in the corpus (i.e. k-means, PLSI, LDA)
* In practice, very difficult to determine the appropriate number of lower dimensions (i.e. concepts)
* Information retrieval needs to support retrieval at all granularities; clustering commits the system to a single granularity

#### Summary

* Vector space model is a straightforward, easy to implement retrieval model
* Principles underlie many modern commercial retrieval systems
* However, there is more ranking than just term matches...

## PageRank

### Beyond Bag of Words

* Document content, especially when using unordered bags of words has limited expressiveness
	* does not capture phrases
	* does not capture metadata
	* does not capture quality
* Oftentimes we are intrested in how a document is consumed
	* do people like me think this is relevant?
	* does this document receive a lot of buzz?
	* is this document authoritative?

### The Value of Credible Information

* There is a lot of junk on the web (e.g. spam, irrelevant forums)
* Knowing what users are reading is a valuable source for knowing what is not junk
* Ideally, we would be able to monitor everything the user is reading and use that information for ranking; this is achieved through toolbars, browsers, operating systems, DNS.
* In 1998, no search companies had browsing data. How did they address this lack of data?

### Random Surfer Model

(Brin and Page 1998)

* Simulate a very large number of users browsing the entire web
* Let users browse randomly. This ia a naive assumption but works okay in practice
* Observe how often pages get visited
* The authoritativeness of a page is a function of its popularity in the simulation

Transition Matrix

* The matrix, G defines a transition matrix over the web graph
* In order to run the simulation, we take the matrix-vector product G x [1,1,1]^T
* The result is a distribution over graph nodes representing where users would have gone have a single simulation step
* We can run the simulation for an arbitrary number of steps, t, by taking powers of the matrix G^T x [1,1,1]^T
* The result of this simulation is the PageRank score for every document in the graph

### PageRank - Extensions

* Build a non-random surfer (Meiss et al. 2010)
* Personalized PageRank (Haveliwala 2003)
* PageRank-directed crawling (Cho and Schonfeld 2007)
* PageRank without links (Kurland and Lee 2005)

### PageRank - Issues

* Need a web graph stored in an efficient data structure
* PageRank requires taking powers of an extemely large matrix
* The PageRank is an approximation of visitation

### Summary

* At the time, PageRank provided a nice surrogate for real user data
* Nowadays, search engines have access to toolbar data, click logs, GPS data, IM, email, social networks, ...
* Nonetheless, the random surfer model is important since the size of the web is much larger than even these data

## Ranking in Practice

* The vector space model measures text-based similarity
* PageRank is claimed to be an important ranking feature, how does it compare?

### Retrieval Metrics

* Retrieval metrics attempt to quantify the quality of a ranked list
* Usually assumed the top of the ranked list is more important that the bottom
* Metrics used in this study,
	* Normalized Discounted Cumulative Gain (NDGG):
		* measures the amount of relevant information in the top of the ranking
		* importance of rank position drops quickly as you scroll down the list
	* Reciprocal Rank (RR)
		* measures the rank of the top relevant result
		* important for navigational queries
	* Mean Average Precision (MAP)
		* measures the amount of relevant information in the top of the ranking
		* decays slightly more slowly than NDGG

### Ranking Signals

* PageRank: static page ranking algorithm
* HITS: static page ranking algorithm based on Kleinberg model (Kleinberg 1998)
* FBM25F: a classic text-based retrieval function similar to the vector space model (Robertson et al. 2004)

### Experiment

* Corpus: 463 billion web pages
* Relevance: 28k queries, with 17 relevance judgements each
* Experiment: for each query, for each signal, rank documents, compute metric; compare average performance

### Summary

* Text-based ranking measures are necessary but not sufficient for high quality retrieval
* Link-baesd ranking measures are important but subtle
* Extemely import to confirm intuition with experiments

## Precision & Recall

### Precision

可以对不分词的查询给较高的boost

{% highlight json linenos %}
{
  "query": {
    "match": {
      "title": "{{ query }}",
      "boost": 5
    },
    "multi_match": {
      "query": "{{ query }}",
      "fields": ["title", "body"]
    }
  }
}
{% endhighlight %}

### Recall

## NLP

### wordseg

```json
{
  "text": "黑帆第二季第二集",
  "tokens": [
   {
      "token": "黑帆",
      "start_offset": 0,
      "end_offset": 2,
      "type": "<noun>",
      "position": 0
   },
   {
     "token": "第二季",
     "start_offset": 2,
     "end_offset": 5,
     "type": "<keyword>",
     "position": 1
   },
   {
     "token": "第二集",
     "start_offset": 5,
     "end_offset": 8,
     "type": "<keyword>",
     "position": 2
   }
  ]
}
```

### synonym

```json
{
  "text": "黑帆第二季第二集",
  "tokens": [
  {
    "token": "黑帆",
    "synonyms": ["black sails"]
  },
  {
    "token": "第二季",
    "synonyms": ["第2季", "S02", "S2"]
  },
  {
    "token": "第二集",
    "synonyms": ["第2集", "E02", "E2"]
  }
  ]
}
```

### wordrank

```json
{
  "text": "黑帆第二季第二集",
  "tokens": [
  {
    "token": "黑帆",
    "weight": 0.70
  },
  {
    "token": "第二季",
    "weight": 0.20
  },
  {
    "token": "第二集",
    "weight": 0.10
  }
  ]
}
```

## ES

### Control relevance

## Similarity

Elasticsearch 5.0 has changed the default similarity from TF/IDF to Okapi BM25.

IDF: how popular is the term in the corpus

language is anbivalent, verbose and many topics in one document.

no clear way to formulate your query, no much information available but a few keywords.

normalization:

* normalize
* synonym

idf: common is less important, but will cause some less common word to be non-related.

bool query and coord-factor

TF/IDF is a heuristic that makes sense intuitively but it is somewhat a guess (Adhoc)

### TF/IDF

### BM25

![termNorm](/assets/bm25-term-norm.svg)

The root of BM25:

If retrieved documents are ordered by decreasing probability of relevance on the data available, then the system's effectiveness is the best that can be obtained for the data.

Estimate relevancy:

* simplification: relevance is binary (relevant or irrelevant)
* get a dataset queries (relevant/irrelevant documents)
* use that to estimate

the binary independence model

query term occurs in a document or doesn't, don't care how often.
a dramatic but useful simplification

TF saturation curve

* limits influence of TF
* allows to tune influence by tweaking k1
* less influence of common words
* no more coord factor
* disable corrd for bool queries
    * index.similarity.default.type = BM25
* lower automatic boost for short fields
    * with TF/IDF, short fields are automatically scored higher
    * BM25: scales field length with average
* field length treatment does not automatically boost short fields (you have to explicitly boost)
* might need to adjust boost

[https://github.com/apache/lucene-solr/blob/master/lucene/core/src/java/org/apache/lucene/search/similarities/BM25Similarity.java](https://github.com/apache/lucene-solr/blob/master/lucene/core/src/java/org/apache/lucene/search/similarities/BM25Similarity.java)

```java
/**
 * BM25 Similarity. Introduced in Stephen E. Robertson, Steve Walker,
 * Susan Jones, Micheline Hancock-Beaulieu, and Mike Gatford. Okapi at TREC-3.
 * In Proceedings of the Third <b>T</b>ext <b>RE</b>trieval <b>C</b>onference (TREC 1994).
 * Gaithersburg, USA, November 1994.
 */
public class BM25Similarity extends Similarity {
  private final float k1;
  private final float b;

  /**
   * BM25 with the supplied parameter values.
   * @param k1 Controls non-linear term frequency normalization (saturation).
   * @param b Controls to what degree document length normalizes tf values.
   * @throws IllegalArgumentException if {@code k1} is infinite or negative, or if {@code b} is 
   *         not within the range {@code [0..1]}
   */
  public BM25Similarity(float k1, float b) {
    if (Float.isFinite(k1) == false || k1 < 0) {
      throw new IllegalArgumentException("illegal k1 value: " + k1 + ", must be a non-negative finite value");
    }
    if (Float.isNaN(b) || b < 0 || b > 1) {
      throw new IllegalArgumentException("illegal b value: " + b + ", must be between 0 and 1");
    }
    this.k1 = k1;
    this.b  = b;
  }

  /** BM25 with these default values:
   * <ul>
   *   <li>{@code k1 = 1.2}</li>
   *   <li>{@code b = 0.75}</li>
   * </ul>
   */
  public BM25Similarity() {
    this(1.2f, 0.75f);
  }
 
  /** Implemented as <code>log(1 + (docCount - docFreq + 0.5)/(docFreq + 0.5))</code>. */
  protected float idf(long docFreq, long docCount) {
    return (float) Math.log(1 + (docCount - docFreq + 0.5D)/(docFreq + 0.5D));
  }
  
  /** Implemented as <code>1 / (distance + 1)</code>. */
  protected float sloppyFreq(int distance) {
    return 1.0f / (distance + 1);
  }
  
  /** The default implementation returns <code>1</code> */
  protected float scorePayload(int doc, int start, int end, BytesRef payload) {
    return 1;
  }
  
  /** The default implementation computes the average as <code>sumTotalTermFreq / docCount</code>,
   * or returns <code>1</code> if the index does not store sumTotalTermFreq:
   * any field that omits frequency information). */
  protected float avgFieldLength(CollectionStatistics collectionStats) {
    final long sumTotalTermFreq = collectionStats.sumTotalTermFreq();
    if (sumTotalTermFreq <= 0) {
      return 1f;       // field does not exist, or stat is unsupported
    } else {
      final long docCount = collectionStats.docCount() == -1 ? collectionStats.maxDoc() : collectionStats.docCount();
      return (float) (sumTotalTermFreq / (double) docCount);
    }
  }
  
  /** The default implementation encodes <code>boost / sqrt(length)</code>
   * with {@link SmallFloat#floatToByte315(float)}.  This is compatible with 
   * Lucene's default implementation.  If you change this, then you should 
   * change {@link #decodeNormValue(byte)} to match. */
  protected byte encodeNormValue(float boost, int fieldLength) {
    return SmallFloat.floatToByte315(boost / (float) Math.sqrt(fieldLength));
  }

  /** The default implementation returns <code>1 / f<sup>2</sup></code>
   * where <code>f</code> is {@link SmallFloat#byte315ToFloat(byte)}. */
  protected float decodeNormValue(byte b) {
    return NORM_TABLE[b & 0xFF];
  }
  
  /** 
   * True if overlap tokens (tokens with a position of increment of zero) are
   * discounted from the document's length.
   */
  protected boolean discountOverlaps = true;

  /** Sets whether overlap tokens (Tokens with 0 position increment) are 
   *  ignored when computing norm.  By default this is true, meaning overlap
   *  tokens do not count when computing norms. */
  public void setDiscountOverlaps(boolean v) {
    discountOverlaps = v;
  }

  /**
   * Returns true if overlap tokens are discounted from the document's length. 
   * @see #setDiscountOverlaps 
   */
  public boolean getDiscountOverlaps() {
    return discountOverlaps;
  }
  
  /** Cache of decoded bytes. */
  private static final float[] NORM_TABLE = new float[256];

  static {
    for (int i = 1; i < 256; i++) {
      float f = SmallFloat.byte315ToFloat((byte)i);
      NORM_TABLE[i] = 1.0f / (f*f);
    }
    NORM_TABLE[0] = 1.0f / NORM_TABLE[255]; // otherwise inf
  }


  @Override
  public final long computeNorm(FieldInvertState state) {
    final int numTerms = discountOverlaps ? state.getLength() - state.getNumOverlap() : state.getLength();
    return encodeNormValue(state.getBoost(), numTerms);
  }

  /**
   * Computes a score factor for a simple term and returns an explanation
   * for that score factor.
   * 
   * <p>
   * The default implementation uses:
   * 
   * <pre class="prettyprint">
   * idf(docFreq, docCount);
   * </pre>
   * 
   * Note that {@link CollectionStatistics#docCount()} is used instead of
   * {@link org.apache.lucene.index.IndexReader#numDocs() IndexReader#numDocs()} because also 
   * {@link TermStatistics#docFreq()} is used, and when the latter 
   * is inaccurate, so is {@link CollectionStatistics#docCount()}, and in the same direction.
   * In addition, {@link CollectionStatistics#docCount()} does not skew when fields are sparse.
   *   
   * @param collectionStats collection-level statistics
   * @param termStats term-level statistics for the term
   * @return an Explain object that includes both an idf score factor 
             and an explanation for the term.
   */
  public Explanation idfExplain(CollectionStatistics collectionStats, TermStatistics termStats) {
    final long df = termStats.docFreq();
    final long docCount = collectionStats.docCount() == -1 ? collectionStats.maxDoc() : collectionStats.docCount();
    final float idf = idf(df, docCount);
    return Explanation.match(idf, "idf, computed as log(1 + (docCount - docFreq + 0.5) / (docFreq + 0.5)) from:",
        Explanation.match(df, "docFreq"),
        Explanation.match(docCount, "docCount"));
  }

  /**
   * Computes a score factor for a phrase.
   * 
   * <p>
   * The default implementation sums the idf factor for
   * each term in the phrase.
   * 
   * @param collectionStats collection-level statistics
   * @param termStats term-level statistics for the terms in the phrase
   * @return an Explain object that includes both an idf 
   *         score factor for the phrase and an explanation 
   *         for each term.
   */
  public Explanation idfExplain(CollectionStatistics collectionStats, TermStatistics termStats[]) {
    double idf = 0d; // sum into a double before casting into a float
    List<Explanation> details = new ArrayList<>();
    for (final TermStatistics stat : termStats ) {
      Explanation idfExplain = idfExplain(collectionStats, stat);
      details.add(idfExplain);
      idf += idfExplain.getValue();
    }
    return Explanation.match((float) idf, "idf(), sum of:", details);
  }

  @Override
  public final SimWeight computeWeight(float boost, CollectionStatistics collectionStats, TermStatistics... termStats) {
    Explanation idf = termStats.length == 1 ? idfExplain(collectionStats, termStats[0]) : idfExplain(collectionStats, termStats);

    float avgdl = avgFieldLength(collectionStats);

    // compute freq-independent part of bm25 equation across all norm values
    float cache[] = new float[256];
    for (int i = 0; i < cache.length; i++) {
      cache[i] = k1 * ((1 - b) + b * decodeNormValue((byte)i) / avgdl);
    }
    return new BM25Stats(collectionStats.field(), boost, idf, avgdl, cache);
  }

  @Override
  public final SimScorer simScorer(SimWeight stats, LeafReaderContext context) throws IOException {
    BM25Stats bm25stats = (BM25Stats) stats;
    return new BM25DocScorer(bm25stats, context.reader().getNormValues(bm25stats.field));
  }
  
  private class BM25DocScorer extends SimScorer {
    private final BM25Stats stats;
    private final float weightValue; // boost * idf * (k1 + 1)
    private final NumericDocValues norms;
    private final float[] cache;
    
    BM25DocScorer(BM25Stats stats, NumericDocValues norms) throws IOException {
      this.stats = stats;
      this.weightValue = stats.weight * (k1 + 1);
      this.cache = stats.cache;
      this.norms = norms;
    }
    
    @Override
    public float score(int doc, float freq) throws IOException {
      // if there are no norms, we act as if b=0
      float norm;
      if (norms == null) {
        norm = k1;
      } else {
        if (norms.advanceExact(doc)) {
          norm = cache[(byte)norms.longValue() & 0xFF];
        } else {
          norm = cache[0];
        }
      }
      return weightValue * freq / (freq + norm);
    }
    
    @Override
    public Explanation explain(int doc, Explanation freq) throws IOException {
      return explainScore(doc, freq, stats, norms);
    }

    @Override
    public float computeSlopFactor(int distance) {
      return sloppyFreq(distance);
    }

    @Override
    public float computePayloadFactor(int doc, int start, int end, BytesRef payload) {
      return scorePayload(doc, start, end, payload);
    }
  }
  
  /** Collection statistics for the BM25 model. */
  private static class BM25Stats extends SimWeight {
    /** BM25's idf */
    private final Explanation idf;
    /** The average document length. */
    private final float avgdl;
    /** query boost */
    private final float boost;
    /** weight (idf * boost) */
    private final float weight;
    /** field name, for pulling norms */
    private final String field;
    /** precomputed norm[256] with k1 * ((1 - b) + b * dl / avgdl) */
    private final float cache[];

    BM25Stats(String field, float boost, Explanation idf, float avgdl, float cache[]) {
      this.field = field;
      this.boost = boost;
      this.idf = idf;
      this.avgdl = avgdl;
      this.cache = cache;
      this.weight = idf.getValue() * boost;
    }

  }

  private Explanation explainTFNorm(int doc, Explanation freq, BM25Stats stats, NumericDocValues norms) throws IOException {
    List<Explanation> subs = new ArrayList<>();
    subs.add(freq);
    subs.add(Explanation.match(k1, "parameter k1"));
    if (norms == null) {
      subs.add(Explanation.match(0, "parameter b (norms omitted for field)"));
      return Explanation.match(
          (freq.getValue() * (k1 + 1)) / (freq.getValue() + k1),
          "tfNorm, computed as (freq * (k1 + 1)) / (freq + k1) from:", subs);
    } else {
      byte norm;
      if (norms.advanceExact(doc)) {
        norm = (byte) norms.longValue();
      } else {
        norm = 0;
      }
      float doclen = decodeNormValue(norm);
      subs.add(Explanation.match(b, "parameter b"));
      subs.add(Explanation.match(stats.avgdl, "avgFieldLength"));
      subs.add(Explanation.match(doclen, "fieldLength"));
      return Explanation.match(
          (freq.getValue() * (k1 + 1)) / (freq.getValue() + k1 * (1 - b + b * doclen/stats.avgdl)),
          "tfNorm, computed as (freq * (k1 + 1)) / (freq + k1 * (1 - b + b * fieldLength / avgFieldLength)) from:", subs);
    }
  }

  private Explanation explainScore(int doc, Explanation freq, BM25Stats stats, NumericDocValues norms) throws IOException {
    Explanation boostExpl = Explanation.match(stats.boost, "boost");
    List<Explanation> subs = new ArrayList<>();
    if (boostExpl.getValue() != 1.0f)
      subs.add(boostExpl);
    subs.add(stats.idf);
    Explanation tfNormExpl = explainTFNorm(doc, freq, stats, norms);
    subs.add(tfNormExpl);
    return Explanation.match(
        boostExpl.getValue() * stats.idf.getValue() * tfNormExpl.getValue(),
        "score(doc="+doc+",freq="+freq+"), product of:", subs);
  }

  @Override
  public String toString() {
    return "BM25(k1=" + k1 + ",b=" + b + ")";
  }
  
  /** 
   * Returns the <code>k1</code> parameter
   * @see #BM25Similarity(float, float) 
   */
  public final float getK1() {
    return k1;
  }
  
  /**
   * Returns the <code>b</code> parameter 
   * @see #BM25Similarity(float, float) 
   */
  public final float getB() {
    return b;
  }
}
```

actor 字段：

* analyzed
* not_analyzed

actor, director 来构造词典

cutoff_frequency

* 提升性能
* 降低高频词干扰

dis_max

取最大得分，可以使用tie_breaker来综合其它匹配的影响。

```json
"minimum_should_match": "1<50%"
```

可以用来过滤

title:

* exact match
    * stopword 丢失
    * 低频词降权
    * lengthNorm
* analyzed
* shingles

文本相关性评分:

* bool
    * actor
    * dis_max
        * title
        * alias

## Boosting

* Lucene 是通用搜索引擎，需要使用boost来完成specific-domain适配
* Adding domain-specific logic
* Incorporating additional signals
    * recency/freshness boost
    * boosting by popularity (more comments or views)
* Filter boost
    * boost articles which has comments or reviews or audited or from official, eliminate function score overhead
    * filter by user preferences
        * content type
        * categories of interest
        * source of interest

Boost should be a multiplier on the relevancy score.

索引文档类型不同可能导致termFreq差异较大，此时可以给因文本较长导致较高的文档类型一个boost（需要注意的是Lucene可以通过lengthNorm自适应，所以boost不宜太大)

### Boosting with Recency/Freshness

Time Decay

* freshness boost
* staleness penalty

```python
if updatedTime == null:
    updatedTime = createdTime
```

Bottom out the old age penalty using `min(recip(...), 0.20)`

* Solr recip
    * y = a/(m*x + b)
    * a = 0.08, b = 0.05, m = 3.16E-11
* Newtow's Law of Cooling

### Boosting with Popularity

view count should be broken into time slots:

* Past
* Last Month
* Last Week
* Recent

view count can be derived from log analysis:

log analysis -> Map/Reduce -> view count

minimum popularity is 1 (not zero), up to 2 or more

`1 + (0.4*Recent + 0.3*LastWeek + 0.2*LastMonth ...)`

## Testing

### Focus Group

### In-house Testing

### A/B Test

### Sort Trends
