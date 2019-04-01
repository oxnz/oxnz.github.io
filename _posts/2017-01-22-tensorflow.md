---
title: TensorFlow
categories: [ml]
tags: [tensorflow]
---

TensorFlow

<!--more-->

## Concepts

1. Data
	1. reading
	2. preprocessing
2. Model
	1. creation
	2. Training
	3. Evaluation

## Logistic Regression

[Logistic Regression](https://cntk.ai/pythondocs/CNTK_101_LogisticRegression.html)

uses a linear weighted combination of features and generates the probability of predicting different classes

>
The softmax function takes an un-normalized vector, and normalizes it into a probability distribution.

binary classification task: `num_output_classes = 2`

## Install

```shell
pip3 install tensorflow
```

### Test

```python
#!/usr/bin/env python3

import tensorflow as tf

hello = tf.constant('Hello, TensorFlow!')
sess = tf.Session()
print(sess.run(hello))
a = tf.constant(10)
b = tf.constant(32)
print(sess.run(a+b))
```

Verify

```python
import tensorflow as tf
tf.enable_eager_execution()
tf.add(1,2)
hello = tf.constant('Hello, TensorFlow!')
```

## Named Entity Recognition/Sequence Tagging

```txt
John  lives in New   York  and works for the European Union
B-PER O     O  B-LOC I-LOC O   O     O   O   B-ORG    I-ORG
```

## MNIST

Softmax Regression

A softmax regression has 2 steps:

1. add up the evidence of input being in certain classes
2. then convert that evidence into probabilities

## References

* https://guillaumegenthial.github.io/sequence-tagging-with-tensorflow.html
* http://karpathy.github.io/
* http://web.stanford.edu/class/cs224n/
* https://opennlp.apache.org/docs/1.9.0/manual/opennlp.html
