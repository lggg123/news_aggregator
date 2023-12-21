const url = 'https://hacker-news.firebaseio.com/v0/newstories.json';
const newRequest = Functions.makeHttpRequest({ url });
const newResponse = await newRequest;
if (newResponse.error) {
    throw Error(`Error fetching news`);
}
const latestStory = newResponse.data[0];
const latestStoryURL = `https://hacker-news.firebaseio.com/v0/item/${latestStory}.json`;
const storyRequest = Functions.makeHttpRequest({ url: latestStoryURL });
const storyResponse = await storyRequest;
return Functions.encodeString(storyResponse.data.url);