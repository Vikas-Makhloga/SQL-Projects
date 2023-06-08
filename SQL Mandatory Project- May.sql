-- Task 1 Create an ER diagram or draw a schema for the given database.
Database -> Reverse Engineer

-- Task 2 We want to reward the user who has been around the longest, Find the 5 oldest users.
Select Id, Username, created_at from users order by 3 asc limit 5;

-- Task 3 To target inactive users in an email ad campaign, find the users who have never posted a photo.
Select Id, Username from users U where
(select Count(*) from photos P where P.user_ID = U.ID) = 0;

-- Task 4 Suppose you are running a contest to find out who got the most likes on a photo. Find out who won? 
Select * from likes; #User_ID(user_ID), Photo_ID(photo_ID)
Select * from users; # ID(user_ID), Username
Select * from photos; # ID(photo_ID), User_ID(User_ID)
Select * from users U where U.ID in
(Select user_ID from photos P
join (Select Photo_ID, Count(*) as count_likes from likes L group by photo_ID order by 2 desc limit 1) as Max_likes
on P.ID = Max_likes.photo_ID);

Select U.ID, U.Username, P.ID from users U 
join Photos P on P.ID = U.ID
Join Likes L on L.user_ID = P.user_ID
where (select Count(photo_ID) as Likes from likes group by photo_ID order by likes desc limit 1);

-- Task 5 The investors want to know how many times does the average user post.
With Photo_Count as
(Select Count(*) as Total_posts from photos),
User_count as
(Select Count(*) as Total_users from users)
Select Round(Total_posts/Total_users, 2) as Avg_user_post from Photo_count, user_count;

-- Task 6 A brand wants to know which hashtag to use on a post, and find the top 5 most used hashtags.
With Tag_counts as
(Select Tag_ID, Count(*) as Tag_counts from photo_tags group by Tag_ID)
Select Tag_name as Hashtag_Name, ID as Hashtag_ID, Tag_counts from tags T
Join Tag_Counts TC on TC.Tag_ID = T.ID
order by 3 Desc Limit 5;

-- Task 7 To find out if there are bots, find users who have liked every single photo on the site.
with User_likes as
(Select user_ID, Count(Photo_ID) as Likes from likes group by user_ID
having Likes = (Select Count(*) from photos))
Select ID, Username, UL.likes from Users U 
join user_likes UL on UL.user_Id = U.ID;
 
 -- Task 8 Find the users who have created instagramid in may and select top 5 newest joinees from it?
 Select ID, username, Created_at as Month from users where monthname(Created_at) = 'may'
 Order by 3 desc limit 5;

-- Task 9 Can you help me find the users whose name starts with c and ends with any number and have posted the 
-- photos as well as liked the photos?
 with cte as
(select id,username from users
where username regexp '^c.*[0-9]$')
select distinct(c.username) as Name,p.user_id as User_id from photos p
join cte c on c.id=p.user_id
join likes l on c.id=l.user_id;

-- Task 10 Demonstrate the top 30 usernames to the company who have posted photos in the range of 3 to 5.
with cte as
(select user_id,count(id) as Posts from photos
group by user_id
having posts between 3 and 5 order by posts desc limit 30)
select usr.username as Name,c.posts from users usr
join cte c on c.user_id=usr.id;
