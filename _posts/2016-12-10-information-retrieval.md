---
title: Infromation Retrieval
---

<script src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>

Information Retrieval
: given a query and a corpus, find relevant documents.

query
: user's expression of the information need

corpus
: the repository of retrievable items

relevance
: satisfaction of the information need

<!--more-->

## Table of Contents

* TOC
{:toc}

## Scoring, term weighting and the vector space model

### Parametric and zone indexes

* meta data
    * author
    * title
    * time
        * created
        * updated
        * published
* parametric index
    * there is one parametric index for each field (e.g. created)
    * allows to select only documents matching the specific date in the query
    * search engine may support querying ranges on ordered values
    * a structure like B-tree may be used for the field's dictionary
* zone
    * zones are similar to fields
    * except the contents of a zone can be arbitrary free text
    * whereas a field may take on a relatively small set of values
    * a zone can be thought of as an arbitrary, unbounded amount of text
    * e.g. document titles and abstracts

#### Weighted zone scoring

given a boolean query q and a document d, weighted zone scoring assigns to the pair (q,d) a score in the interval [0,1], by computing a linear combination of *zone scores*, where each zone of the document contributes a Boolean value.

suppose there is a set of documents each of which has n zones, let

$$a_1,a_2,...,a_n \in [0,1]$$

such that

$$\sum_{i=1}^na_i=1$$

$$s_i = score(q,zone_i)$$

the weighted zone score would be

$$\sum_{i=1}^na_is_i$$

weighted zone scoring is sometimes referred to also as ranked boolean retrieval

```python
def zoneScore(terms):
  scores[n] <- 0
  constant a[n]
  p1 = postings(term1)
  p2 = postings(term2)
  while p1 != None and p2 != None:
    if docID(p1) == docID(p2):
      scores[docID(p1)] = weightedZone(p1, p2, a)
      p1 = p1->next()
      p2 = p2->next()
    else if docID(p1) < docID(p2):
      p1 = p1->next()
      p2 = p2->next()
  return scores
```

#### Learning weights

These weights are "learned" using training examples that have been judged editorially.

This methodology falls under a general class of approaches to scoring and ranking in information retrieval, known as machine-learned relevance.

We provide a brief introduction to this topic here because weighted zone scoring presents a clean setting for introducing it; a complete development demands an understanding of machine learning

For weighted zone scoring, the process may be viewed as learning a linear function of the Boolean match scores contributed by the various zones.

The expensive component of this methodology is the labor-intensive assembly of user-generated relevance judgments from which to learn the weights, especially in a collection that changes frequently (such as the Web). We now detail a simple example that illustrates how we can reduce the problem of learning the weights $g_i$ to a simple optimization problem.

title score:

$$s_T(d,q)$$

body score:

$$s_B(d,q)$$

total score:

$$score(d,q) = g*s_T(d,q)+(1-g)s_B(d,q)$$

training example $$\Phi_j$$

$$\epsilon(g,\Phi_j) = (r(d_j,q_j)-score(d_j,q_j))^2$$

total error of a set of training examples:

$$\sum_j{\epsilon(g,\Phi_j)}$$

The problem of learning the constant $g$ from the given training examples then reduces to picking the value of $g$ that minimizes the total error in above formular.

#### The optimal weight g

$$n_{01r}: s_T(d_j,q_j) = 0, s_B(d_j,q_j) = 1, relavent$$

total error:

$$(n_{01r}+n_{10n})g^2+(n_{10r}+n_{01n})(1-g)^2+n_{00r}+n_{11n}$$

By differentiating above Equation with respect to g and setting the result to zero, it follows that the optimal value of g is:

$$\frac{n_{10r}+n_{01n}}{n_{10r}+n_{10n}+n_{01r}+n_{01n}}$$

### Term frequency and weighting

The simplest approach is to assign the weight to be equal to the number of occurrences of term t in document d. This weighting scheme is referred to as term frequency and is denoted

$$tf_{t,d}$$

not all words in a document are equally important.

stop words - words that we decide not to index at all, and therefore do not contribute in any way to retrieval and scoring.

#### Inverse document frequency

Raw term frequency as above suffers from a critical problem: all terms are considered equally important when it comes to assessing relevancy on a query.

An immediate idea is to scale down the term weights of terms with high collection frequency, defined to be the total number of occurrences of a term in the collection. The idea would be to reduce the tf weight of a term by a factor that grows with its collection frequency.

collection frequency
: the total number of occurrences of a term in the collection


document frequency
: $$df_t$$, the number of documents in the collection that contain a term

The reason to prefer df to cf is that collection frequency (cf) and doucment frequency (df) can behave rather differently.

inverse document frequency of a term t:

$$idf_t = log{\frac{N}{df_t}}$$

Thus the idf of a rare term is high, whereas the idf of a frequent term is likely to be low. 

![idf](/assets/information-retrieval-idf.svg)

#### Tf-idf weighting

We now combine the definitions of term frequency and inverse document frequency, to produce a composite weight for each term in each document. The tf-idf weighting scheme assigns to term t a weight in document d given by

$$tf-idf_{t,d} = tf_{t,d} \times idf_t$$

tf-idf assigns to term t a weight in document d that is:

* highest when t occurs many times within a small number of documents (thus lending high discriminating power to those documents)
* lower when the term occurs fewer times in a document, or occurs in many documents (thus offering a less pronouced relevance signal)
* lowest when the term occurs in virtually all documents

overlap score measure
: the score of a document d is the sum, over all query terms, of the number of times each of the query terms occurs in d
we can refine this idea so that we add up not the number of occurrences of each query term t in d, but instead the tf-idf weight of each term in d:

$$score(q,d) = \sum_{t \in q}{tf-idf_{t,d}}$$

At this point, we may view each document as a vector with one component corresponding to each term in the dictionary, together with a weight for each component that is given by tf-idf, For dictionary terms that do not occur in a document, this weight is zero. This vector form will prove to be crucial to scoring and ranking;

### The vector space model for scoring

#### Dot products

vector derived from document d:

$$\vec{V_{(d)}}$$

with one component in the vector for each dictionary term.
the components are computed using the tf-idf weighting scheme.
The set of documents in a collection then may be viewed as a set of vectors in a vector space, in which there is one axis for each term. This representation loses the relative ordering of the terms in each document.

To compensate for the effect of document length, the standard way of quantifying the similarity between two documents d1 and d2 is to compute the cosine similarity of their vector:

$$sim(d_1,d_2) = \frac{\vec{V}(d_1)\cdot\vec{V}(d_2)}{|\vec{V}(d_1)||\vec{V}(d_2)|}$$

where the numerator represents the dot product (also known as the inner product ),
while the denominator is the product of their Euclidean lengths.

The effect of the denominator of above Equation is to length-normalize the vectors to unit vectors. we can rewrite the above equation as:

$$sim(d_1,d_2) = \vec{v}(d_1)\cdot\vec{v}(d_2)$$

similarity measure usage:
consider searching for the documents in the collection most similar to d.
Such a search is useful in a system where a user may identify a document and seek others like it -
a feature available in the results lists of search engines as a more like this feature.

Viewing a collection of N documents as a collection of vectors leads to a natural view of a collection as a term-document matrix

#### Queries as vectors

There is a far more compelling reason to represent documents as vectors: we can also view a query as a vector.

By viewing a query as a "bag of words", we are able to treat it as a very short document.
As a consequence, we can use the cosine similarity between the query vector and a document vector as a measure of the score of the document for that query.
The resulting scores can then be used to select the top-scoring documents for a query

$$score(q,d) = \frac{\vec{V}(q)\cdot\vec{V}(d)}{|\vec{V}(q)||\vec{V}(d)|}$$

A document may have a high cosine score for a query even if it does not contain all query terms.

Note that the preceding discussion does not hinge on any specific weighting of terms in the document vector, although for the present we may think of them as either tf or tf-idf weights. In fact, a number of weighting schemes are possible for query as well as document vectors.

#### Computing vector scores

top K

```python
def cosineScore(q):
    scores[N] = 0
    length[N] = length_normalization_factors()
    for t in q:
        w(t,q) = calc()
        for d, tf(t,d) in postings(t):
            scores[d] += wftd x wtq
    for d:
        scores[d] = scores[d]/length[d]
    return topK(scores)
```

This process of adding in contributions one query term at a time is sometimes known as term-at-a-time scoring or accumulation.

top K - this requires a priority queue data structure, often implemented using a heap.

we could in fact traverse postings concurrently, In such a concurrent postings traversal we compute the scores of one document at a time, so that it is sometimes called document-at-a-time scoring.

### Variant tf-idf functions

For assigning a weight for each term in each document, a number of alternatives to tf and tf-idf have been considered.

#### Sublinear tf scaling

It seems unlikely that twenty occurneces of a term in a document truly carry twenty times the significance of a single occurnece.
Accordingly, there has been considerable research into variants of term frequency that go beyond counting the number of occurences of a term.
A common modification is to use instead the logarithm of the term frequency, which assigns a weight given by

$$ wf_{t,d} = \begin {cases}
1+\log{tf_{t,d}}, if tf_{t,d} > 0 \\\
0, otherwise
\end {cases} $$

In this form, we may replace tf by some other function wf as in above eqaution to obtain:

$$wf-idf_{t,d} = wf_{t,d} \times idf_t$$

score equation can then be modified by replacing tf-idf by wf-idf as define above.

#### Maximum tf normalization

One well-studied technique is to normalize the tf weights of all terms occurring in a document by the maximum tf in that document.

for each document d, let

$$tf_{max}(d) = max_{\tau \in d}tf_{\tau,d}$$

where &tau; ranges over all terms in d.
Then, we compute a normalized term frequency for each &tau; in document d by

$$ntf_{t,d} = a + (1-a)\frac{tf_{t,d}}{tf_{max}(d)}$$

where a is a value between 0 and 1 and is generally set to 0.4, although some eary work used the value 0.5.
The term a in above equation is a smoothing term whose role is to damp the contribution of the second term - which may be viewed as a scaling down of tf by the largest tf value in d.
The basic idea is to avoid a large swing in ntf(t,d) from modest changes in tf(t,d) (say from 1 to 2).

The main idea of maximum tf normalization is to mitigate the following anomaly:
we observe higher term frequencies in longer documents, merely because longer documents tend to repeat the same words over and over again. To appreciate this, consider the following extreme example: supposed we were to take a document d and create a new document d1 by simply appending a copy of d to itself.
While d1 should be no more relevant to any query than d is. Replacing tf-idf by ntf-idf in score equation eliminates the anormaly in this example.

Maximum tf normalization does suffer from the following issues:
* The method is unstable in the following sense: a change in the stop word list can dramatically alter term weightings (and therefore ranking). Thus, it is hard to tune.
* A document may contain an outlier term with an unusually large number of occurrences of that term, not representative of the content of that document.
* More generally, a document in which the most frequent term appears roughly as often as many other terms should be treated differently from one with a more skewed distribution.

#### Document and query weighting schemes

cosine similarity equation is fundamental to information retrieval systems that use any form of vector space scoring.

Term frequency

name | formular
n(natural) | $$tf_{t,d}$$
l(logarithm) | $$1+log(tf_{t,d})$$
a(augmented) | $$0.5 + \frac{0.5\times tf_{t,d}}{max_t(tf_{t,d})}$$
b(boolean) | $$\begin{cases}1, if tf_{t,d} > 0\\0, otherwise\end{cases}$$
L(logave) | $$\frac{1+log(tf_{t,d})}{1+log(ave_{t\in d}(tf_{t,d}))}$$

Document frequency

name | formular
n(no) | 1
t(idf) | $$log\frac{N}{df_t}$$
p(prob idf) | $$max\{0,log\frac{N-df_t}{df_t}\}$$

Normalization

name | formular
n(none) | 1
c(cosine) | $$\frac{1}{sqrt{w_1^2+w_2^2+...+w_M^2}}$$
u(pivoted unique) | $$\frac{1}{u}$$
b(byte size) | $$\frac{1}{CharLength^\alpha}, \alpha<1$$

SMART notation

* lnc.ltc
    * document vector
        * log-weighted term frequency
        * no idf (for both effectiveness and efficiency reasons)
        * cosine normalization
    * query vector
        * log-weighted term frequency
        * idf weighting
        * cosine normalization

#### Pivoted normalized document length

In previous section, we normalized each document vector by the Enclidean length of the vector, so that all document vectors turn into unit vectors.
Doing so, we eliminated all information on the length of the original document.
This masks some subtleties about longer documents:

* longer documents will - as a result of containing more terms - have higher tf values
* longer documents contain more distinct terms

These factors can conspire to raise the scores of longer documents, which (at least for some information needs) is unnatural. Longer documents can broadly be lumped into two categories:

1. verbose documents that essentially repeat the same content - in these, the length of the document does not alter the relative weights of different terms
2. documents covering multiple different topics, in which the search terms probably match small segments of the document but not all of it - in this case, the relative weights of terms are quite different from a single short document that matches the query terms.

Compensating for this phenomenon is a form of document length normalization that is independent of term and document frequencies.

To this end, we introduce a form of normalizing the vector representations of documents in the collection, so that the resulting "normalized" documents are not necessarily of unit length.
Then, when we compute the dot product score between a (unit) query vector and such a normalized document, the score is skewed to account for the effect of document length on relevance. This form of compensation for document length is known as pivoted document length normalization.

pivoted length normalization:

it is linear in the document length and has the form

$$a|\vec{V}(d)|+(1-a)piv$$

where piv is the cosine normalization value at which the two curves intersect.

Its slope is a<1 and it crosses the y=x line at piv

It has been argued that in practice, above equation is well approximated by

$$au_d+(1-a)piv$$

where ud is the number of unique terms in document d

One measure of the similarity of two vectors is the Euclidean distance (or  L_2 distance ) between them:

$$|\vec{x}-\vec{y}| = \sqrt{\sum_{i=1}^M(x_i-y_i)^2}$$

## References

lucene support:

* Boolean Model (BM)
* Vector Space Model (VSM)

documents "approved" by BM are scored by VSM

cosine similarity between the query vector and a document vector as a measure of the score of the document for that query.

$$score(q,d) = \frac{\vec{V}(q)\cdot\vec{V}(d)}{|\vec{V}(q)||\vec{V}(d)|}$$

The number of demensions will equal the vocabulary size M

* [http://nlp.stanford.edu/IR-book/html](http://nlp.stanford.edu/IR-book/html)
* [http://cis.poly.edu/cs6093/lecture03.pdf](http://cis.poly.edu/cs6093/lecture03.pdf)
