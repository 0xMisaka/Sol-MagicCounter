<h2>The Most efficient Counter (LFU Cache) in Solidity and Foundry.</h2>

The *Magic* Counter supports the following operations all in O(1):

- Increment and decrement the count of each key: increment(uint key) , decrement(uint key)
- Find the keys with min and max count: getMinKeys() , getMaxKeys()


**How is this useful โ๏ธ?**

This is very useful for something like the Least Frequently Used cache (LFU)

For the LFU cache, you need to know the keys with min or max count at a certain point in the data stream in the most efficient way possible.



**How Efficient ๐?**

Letโs take a look at time complexity:

For the non-technical readers: Time complexity measures the computational power, ranging from O(1), O(log(n), O(n), the lower the better.

As you can see, MagicCounter outperforms other functions in every category.


|  | MagicCounter  ๐ช | Binary Search Tree | Simple Counter |
| --- | --- | --- | --- |
| Increment | O(1) ๐ | O(log(n)) ๐ข | O(1) ๐ |
| Decrement | O(1) ๐ | O(log(n)) ๐ข | O(1) ๐ |
| GetMax | O(1) ๐ | O(1) ๐ | O(n) ๐  |
| GetMin | O(1) ๐ | O(1) ๐ | O(n) ๐  |


**How does this work๐?**

It works by creating a doubly LinkedListโ๏ธ of *Bucket* which tracks: its count, next & previous bucket, and the keys where all the keys in that bucket have the same count.

You can query the max or min Keys by looking at the  head or tail bucket

![LFU Cache](https://miro.medium.com/max/704/1*fSJpm1tKWC0h_msc1BQStQ.jpeg)

This approach has already been used by a lot of Operating Systems๐คfor various use cases (cache, memory management, etc).

I thought it would be really cool to implement it using solidity.





