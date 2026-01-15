drop database if exists social_network;
create database social_network;
use social_network;
create table users (
    user_id int auto_increment primary key,
    username varchar(50) not null,
    posts_count int default 0,
    following_count int default 0,
    followers_count int default 0,
    friends_count int default 0
);
create table posts (
    post_id int auto_increment primary key,
    user_id int not null,
    content text not null,
    created_at datetime default current_timestamp,
    likes_count int default 0,
    comments_count int default 0,
    foreign key (user_id) references users(user_id)
);
create table likes (
    like_id int auto_increment primary key,
    post_id int not null,
    user_id int not null,
    unique key unique_like (post_id, user_id),
    foreign key (post_id) references posts(post_id),
    foreign key (user_id) references users(user_id)
);
create table followers (
    follower_id int not null,
    followed_id int not null,
    primary key (follower_id, followed_id)
);
create table comments (
    comment_id int auto_increment primary key,
    post_id int not null,
    user_id int not null,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key (post_id) references posts(post_id),
    foreign key (user_id) references users(user_id)
);
create table friend_requests (
    request_id int auto_increment primary key,
    from_user_id int,
    to_user_id int,
    status enum('pending','accepted','rejected') default 'pending'
);

create table friends (
    user_id int,
    friend_id int,
    primary key (user_id, friend_id)
);
insert into users(username) values ('A'), ('B'), ('C');
-- BÀI 1: ĐĂNG BÀI VIẾT (TRANSACTION)
start transaction;
insert into posts(user_id, content) values (1, 'Bai viet dau tien');
update users set posts_count = posts_count + 1 where user_id = 1;
commit;
-- Test lỗi (rollback)
start transaction;
insert into posts(user_id, content) values (999, 'Loi khoa ngoai');
update users
set posts_count = posts_count + 1 where user_id = 999;
rollback;
-- BÀI 2: LIKE BÀI VIẾT (TRANSACTION)
start transaction;
insert into likes(post_id, user_id) values (1, 2);
update posts set likes_count = likes_count + 1
where post_id = 1;
commit;
-- Like lần 2 (rollback do unique)
start transaction;
insert into likes(post_id, user_id) values (1, 2);
update posts set likes_count = likes_count + 1
where post_id = 1;
rollback;
-- BÀI 3: FOLLOW USER (PROCEDURE)
delimiter $$
create procedure sp_follow_user(
    in p_follower_id int,
    in p_followed_id int
)
begin
    start transaction;
    if p_follower_id = p_followed_id then
        rollback;
    elseif not exists (select 1 from users where user_id = p_follower_id)
        or not exists (select 1 from users where user_id = p_followed_id) then
        rollback;
    elseif exists (
        select 1 from followers where follower_id = p_follower_id and followed_id = p_followed_id
    ) then
        rollback;
    else
        insert into followers values (p_follower_id, p_followed_id);
        update users set following_count = following_count + 1 where user_id = p_follower_id;
        update users set followers_count = followers_count + 1 where user_id = p_followed_id;
        commit;
    end if;
end$$
delimiter ;
call sp_follow_user(1, 2);
call sp_follow_user(1, 1); -- lỗi
-- BÀI 4: COMMENT + SAVEPOINT
delimiter $$
create procedure sp_post_comment(
    in p_post_id int,
    in p_user_id int,
    in p_content text
)
begin
    start transaction;
    insert into comments(post_id, user_id, content)
    values (p_post_id, p_user_id, p_content);
    savepoint after_insert;
    update posts
    set comments_count = comments_count + 1
    where post_id = p_post_id;
    commit;
end$$
delimiter ;
call sp_post_comment(1, 2, 'Binh luan dau tien');
-- BÀI 5: ROLLBACK PARTIAL (MÔ PHỎNG LỖI)
delimiter $$
create procedure sp_post_comment_error(
    in p_post_id int,
    in p_user_id int,
    in p_content text
)
begin
    start transaction;
    insert into comments(post_id, user_id, content)
    values (p_post_id, p_user_id, p_content);
    savepoint after_insert;
    -- gây lỗi
    update posts
    set comments_count = comments_count + 1
    where post_id = 999;
    rollback to after_insert;
    commit;
end$$
delimiter ;
call sp_post_comment_error(1, 2, 'Comment loi');
-- BÀI 6: CHẤP NHẬN KẾT BẠN
delimiter $$
create procedure sp_accept_friend_request(
    in p_request_id int,
    in p_to_user_id int
)
begin
    declare v_from_user int;
    set transaction isolation level repeatable read;
    start transaction;
    if not exists (
        select 1 from friend_requests
        where request_id = p_request_id
          and to_user_id = p_to_user_id
          and status = 'pending'
    ) then
        rollback;
    else
        select from_user_id
        into v_from_user
        from friend_requests
        where request_id = p_request_id;
        if exists (
            select 1 from friends
            where user_id = p_to_user_id
              and friend_id = v_from_user
        ) then
            rollback;
        else
            insert into friends values (p_to_user_id, v_from_user);
            insert into friends values (v_from_user, p_to_user_id);
            update users
            set friends_count = friends_count + 1
            where user_id in (p_to_user_id, v_from_user);
            update friend_requests
            set status = 'accepted'
            where request_id = p_request_id;

            commit;
        end if;
    end if;
end$$
delimiter ;
-- test bài 6
insert into friend_requests(from_user_id, to_user_id)
values (1, 3);
call sp_accept_friend_request(1, 3);