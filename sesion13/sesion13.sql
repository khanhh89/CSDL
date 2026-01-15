create database social_network_db;
use social_network_db;
create table users (
    user_id int auto_increment primary key,
    username varchar(50) not null unique,
    email varchar(100) not null unique,
    created_at date,
    follower_count int default 0,
    post_count int default 0
);
create table posts (
    post_id int auto_increment primary key,
    user_id int,
    content text,
    created_at datetime,
    like_count int default 0,
    constraint fk_posts_users
        foreign key (user_id)
        references users(user_id)
        on delete cascade
);
insert into users (username, email, created_at) values
('alice', 'alice@example.com', '2025-01-01'),
('bob', 'bob@example.com', '2025-01-02'),
('charlie', 'charlie@example.com', '2025-01-03');

delimiter //
create trigger trg_after_insert_posts
after insert on posts
for each row
begin
    update users
    set post_count = post_count + 1
    where user_id = new.user_id;
end//
delimiter ;

delimiter //
create trigger trg_after_delete_posts
after delete on posts
for each row
begin
    update users
    set post_count = post_count - 1
    where user_id = old.user_id;
end//
delimiter ;

insert into posts (user_id, content, created_at) values
(1, 'Hello world from Alice!', '2025-01-10 10:00:00'),
(1, 'Second post by Alice', '2025-01-10 12:00:00'),
(2, 'Bob first post', '2025-01-11 09:00:00'),
(3, 'Charlie sharing thoughts', '2025-01-12 15:00:00');

select * from users;
delete from posts where post_id = 2;

-- bt2
create table likes (
    like_id int auto_increment primary key,
    user_id int,
    post_id int,
    liked_at datetime default current_timestamp,
    constraint fk_likes_users
        foreign key (user_id)
        references users(user_id)
        on delete cascade,
    constraint fk_likes_posts
        foreign key (post_id)
        references posts(post_id)
        on delete cascade
);
insert into likes (user_id, post_id, liked_at) values
(2, 1, '2025-01-10 11:00:00'),
(3, 1, '2025-01-10 13:00:00'),
(1, 3, '2025-01-11 10:00:00'),
(3, 4, '2025-01-12 16:00:00');

delimiter //
create trigger trg_after_insert_likes
after insert on likes
for each row
begin
    update posts
    set like_count = like_count + 1
    where post_id = new.post_id;
end//
delimiter ;

delimiter //
create trigger trg_after_delete_likes
after delete on likes
for each row
begin
    update posts
    set like_count = like_count - 1
    where post_id = old.post_id;
end//
delimiter ;

create view user_statistics as
select 
    u.user_id,
    u.username,
    u.post_count,
    ifnull(sum(p.like_count), 0) as total_likes
from users u
left join posts p on u.user_id = p.user_id
group by u.user_id, u.username, u.post_count;
insert into likes (user_id, post_id, liked_at)
values (2, 4, now());
select * from posts where post_id = 4;
select * from user_statistics;
delete from likes where user_id = 2 and post_id = 4;
select * from user_statistics;

-- bt3
delimiter //
create trigger trg_before_insert_likes
before insert on likes
for each row
begin
    if new.user_id = (select user_id from posts where post_id = new.post_id) then
        set new.post_id = -1;
    end if;
end//
delimiter ;
insert into likes (user_id, post_id) values (1, 1);
insert into likes (user_id, post_id) values (2, 1);
-- bt4
create table post_history (
    history_id int auto_increment primary key,
    post_id int,
    old_content text,
    new_content text,
    changed_at datetime,
    changed_by_user_id int,
    constraint fk_history_posts
        foreign key (post_id)
        references posts(post_id)
        on delete cascade
);
delimiter //
create trigger trg_before_update_posts
before update on posts
for each row
begin
    -- Chỉ lưu lịch sử khi nội dung thay đổi
    if old.content <> new.content then
        insert into post_history (post_id,old_content,new_content,changed_at,changed_by_user_id) values (old.post_id, old.content, new.content,now(),old.user_id);
    end if;
end//
delimiter ;
update posts set content = 'Hello world from Alice (edited)' where post_id = 1;
update posts set content = 'Bob first post (updated)'where post_id = 3;
select * from post_history;

-- bt5
delimiter //
create procedure add_user(
    in p_username varchar(50),
    in p_email varchar(100),
    in p_created_at date
)
begin
    insert into users (username, email, created_at)
    values (p_username, p_email, p_created_at);
end//
delimiter ;

delimiter //
create trigger trg_before_insert_users
before insert on users
for each row
begin
    if instr(new.email, '@') = 0 or instr(new.email, '.') = 0 then
        set new.email = null;
    end if;
    if instr(new.username, ' ') > 0 then
        set new.username = null;
    end if;
end//
delimiter ;

call add_user('abc def', 'abc@gmail.com', '2025-02-01');

Column 'username' cannot be null

call add_user('abcdef', 'abcgmail.com', '2025-02-01');

-- bt6 
create table friendships (
    follower_id int,
    followee_id int,
    status enum('pending', 'accepted') default 'accepted',
    primary key (follower_id, followee_id),
    foreign key (follower_id) references users(user_id) on delete cascade,
    foreign key (followee_id) references users(user_id) on delete cascade
);
delimiter //
create trigger trg_after_insert_friendship
after insert on friendships
for each row
begin
    if new.status = 'accepted' then
        update users set follower_count = follower_count + 1 where user_id = new.followee_id;
    end if;
end//
delimiter ;
delimiter //
create trigger trg_after_delete_friendship
after delete on friendships
for each row
begin
    if old.status = 'accepted' then
        update users set follower_count = follower_count - 1 where user_id = old.followee_id;
    end if;
end//
delimiter ;

delimiter //

create procedure follow_user(
    in p_follower int,
    in p_followee int,
    in p_status enum('pending', 'accepted')
)
begin
    if p_follower <> p_followee then
        if not exists (
            select 1 from friendships where follower_id = p_follower and followee_id = p_followee
        ) then
            insert into friendships (follower_id, followee_id, status)values (p_follower, p_followee, p_status);
        end if;
    end if;
end//
delimiter ;
call follow_user(1, 2, 'accepted');
call follow_user(3, 2, 'accepted');
delete from friendships where follower_id = 1 and followee_id = 2;
select * from users;
select * from user_profile;
