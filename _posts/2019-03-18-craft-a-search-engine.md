---
title: Craft a search engine
layout: post
---

## Architecture

Document -> DocumentParser -> Indexer -> index
Query -> QueryParser-> Searcher -> IntentDetector -> QueryRewriter

## Query Intent Detection

* benefits
	* display semantically enriched search results.
	* improve ranking results by triggering a vertical search engine in a certain domain
* challenging task
	* queries are usually short
	* requires more context beyond the keywords
	* number of intent categories could be very high
* approches
	* rule-based (precise while coverage is low, bad for scaling)
		* defining patterns for each intent class
		* defining discriminative features for queries to run statistical models
	* statistical methods
		* supervised/unsupervised

### CNN

extract **query vector representations** as the feature for the query classification.

In this model, queries are represented as vectors so that semantically similar queries can be captured by embedding them into a vector space.

**word vector representations**(such as `word2vec`)

* supervised method
	* feature engineering (require domain knowledge)
	* lead to state-of-the-art systems
	* use various type of features
		* search sessions
		* click-through data
		* Wikipedia concepts
* CNN method
	* DO NOT engineering query features
	* use CNN to automatically extract query vectors as the feature
	* architecture
		1. traning the model parameters in the offline time
			* utlize the labeled queries to learn the parameters of CNN and the intent classifier
		2. running the model over new queries in the online time

```
# train
[Queries with intents] -> (CNN) -> [Query vectors with intents] -> [Classifier]
# predict
[New query] -> (CNN) -> [Query vector] -> (Classifier) -> [Predicted intent]
```

## Search Session

## References

* [http://people.cs.pitt.edu/~hashemi/papers/QRUMS2016_HBHashemi.pdf](http://people.cs.pitt.edu/~hashemi/papers/QRUMS2016_HBHashemi.pdf)
