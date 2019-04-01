---
title: Query Intent Detection
---

## Introduction

现代搜索引擎已经不再是简单搜索文档了。为了满足用户的检索需求，需要给出精确的答案。因此，也就需要对用户的query有更深的理解。
(Identifying the intent behind the query) 识别query之后的搜索意图是达成这个目标的一个关键步骤。这不仅仅能帮助从语义上丰富搜索结果，也能帮助搜索结果排序 （例如垂直搜索引擎）

意图识别是富有挑战的工作。因为query往往较短，(identifying the exact intent of the user) 识别用户query的精确意图需出了关键字之外，还要更多的上下文信息。而且，意图的种类往往是非常多的。很多的意图识别方式需要大量的人工努力（human effort）来面对这些挑战，要不就是通过为每个意图类定义模式（defining patterns for each intent class），要不就是定义特征并执行数据分析模型（by defining discriminative features for queries to run statistical models）。
相反的，这里提出一种统计学方法，可以为query自动提取判别特征。

<!--more-->

我们的方式是使用深度学习来找出 query vector representations。然后使用这些特征来按照意图分类。使用query vector representations 的一个好处是可以把这些嵌入一个空间内，这样以来，语意上 （semantically）相似的query距离也比较近。

深度学习多用于文本处理任务，通过使用word vector representations （例如 word2vec），是一些列向量，语意特征编码在纬度中（with encoded semantic features of words in their dimensions）。

本文中，我们将使用 query vector representations 利用 convolutional neural netowrks （CNN）来在word vector representations 之上进行训练。 CNN 原本是发明用来做机器视觉的，近来被证明在自然语言处理和信息检索（Information Retrieval）任务中非常有用，例如语意分析（semantic parsing），句子建模（sentence modeling），文档打分（document ranking），文档相似度（document similarity）和query reformulation。但是我们的任务又和sentence embeddings不同，因为queyr embeddings往往较短，并且是非结构化的。也不同于query embeddings，因为它不使用多种类型的特征，例如click-through data 或者search sessions。

这个文档中，我们通过把意图识别作为一个多分类的分类任务（multi-class classification task）使用提取的query vector representations作为特征。结果展示了从预训练的CNN模型中提取的query vectors 在意图识别中表现良好，可以跟bag-of-word特征相匹敌。另外，虽然她们是从训练数据中自动学习获得的，可以轻易的超过小心设计的基于角色的方式。

## RELATED WORK

和大多数自然语言处理任务一样，query意图识别主要有两种方法：rule-based和statiscal methods。rule-based systems 使用预定于的rules来匹配新query来识别意图。这些系统一般而言是比较精确的（也就是说，如果她们检测到了一个意图，那么这个意图识别在大多数情况下是正确的），但是这种方式的覆盖率太低（也就是说，因为rules的短缺，导致不能识别非常多的query）。还有，这些rules需要专家小心调整，设计新的rule需要耗费较多资源，因此，要扩大系统需要定义更多的rule，需要更多的资源消耗。

statistical models 是另一种比较流行的方法，使用监督或者无监督方式。使用监督方式时，一个分类器被训练来使用学习一个query集合以及她们的模型参数特征。然后给定一个新query，这个分类器就可以进行分类，识别出其意图。然而，这些方法的一个前提条件就是设计discriminative features。这个任务成为feature engineering 并且需要领域特定知识。使用这些特征将会构造state-of-the-art systems。以前的研究使用了各种各样不同类型的feature，例如search sessions，click-through data，和Wikipedia concepts。在本文中，我们将自动生成query vector representations作为feawture set，五代man-made classification features。

## QUERY INTENT IDENTIFICATION

这一节中，我们将描述我们的模型和一个contrastive systems set用作意图识别的baselines。

### Our Method

我们的方式是基于分类的（classification-based approach），但是使用convolutional neural netowrks （CNN）来自动提取query vectors 作为features。

#### Model Architecture

我们的模型主要有两个steps：

1. 离线训练参数模型
2. 在线运行模型识别新query

在训练过程中，我们利用labeled queries来学习the parameters of convolutional neural networks and the intent classifier。
在执行期间，我们传递新query给这两个组件（CNN & Classifier）来识别意图。

```
# Train time/offline
Queries with intents -> CNN -> Query vectors with intents -> Classifier
# Test time/offline
New Query -> CNN -> Query Vector -> Classifier -> Predicted intent
```

#### Convolutional Neural Networks （CNN）

给定一个query，convolutional neural network 组建的目标是找到它的vector representation。我们使用 CNN architecture of Collobert et al. 和它的变种实现by Kim。我们在测试期间对其稍作修改，通过在max pooling layer 之后移除softmax layer 来获取query representations。拥有了query vector representations将会帮助我们结合她们和其它query features 例如语言模型。下图展示了运行期间的CNN 模型。

```
Word vectors in query matrix -> Multiple filters -> Max pooling Query Vector
```
The query representations are trained on top of pre-trained word vectors which are updated during CNN training.We use the publicly available word2vec [11] vectors that are trained on Google News.

### Contrastive Methods

#### Rule-based system

#### Bag-of-words Features

#### Aggregated Word Vector Features

## Experiments

### Data

### Experimental Setup

### Results and Discussion

#### Low-level intent detection

#### High-level intent detection

#### Query clustering

## Conclusion and Future Work

## References

* [Query Intent Detection using Convolutional Neural Networks](http://people.cs.pitt.edu/~hashemi/papers/QRUMS2016_HBHashemi.pdf)
* [http://vision.stanford.edu/teaching/cs231n/](http://vision.stanford.edu/teaching/cs231n/)
