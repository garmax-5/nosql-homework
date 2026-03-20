create keyspace post_ks
            WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

use post_ks;

create table posts_by_user
(
    post_id    int,
    user_id    int,
    username   text,
    content    text,
    created_at timestamp,
    PRIMARY KEY (user_id, created_at, post_id)
) with clustering order by (created_at desc);

insert into posts_by_user (post_id, user_id, username, content, created_at)
values (1, 1, 'alina', 'Learning Redis', '2026-03-14 10:00:00');

insert into posts_by_user (post_id, user_id, username, content, created_at)
values (2, 1, 'alina', 'Learning Scylla', '2026-03-14 11:15:00');

insert into posts_by_user (post_id, user_id, username, content, created_at)
values (3, 2, 'maxim', 'Java vs Kotlin', '2026-03-14 09:30:00');

insert into posts_by_user (post_id, user_id, username, content, created_at)
values (4, 2, 'maxim', 'Using date and timestamp as partition key and clustering key', '2026-03-15 08:45:00');

insert into posts_by_user (post_id, user_id, username, content, created_at)
values (5, 3, 'oleg', 'Data Modeling and Application Development', '2026-03-14 14:20:00');

insert into posts_by_user (post_id, user_id, username, content, created_at)
values (6, 3, 'oleg', 'Rate Limiting Algorithms', '2026-03-15 12:10:00');

create table posts_by_topic
(
    topic_id   int,
    post_id    int,
    user_id    int,
    day        date,
    username   text,
    created_at timestamp,
    PRIMARY KEY ((topic_id, day), created_at, post_id)
) with clustering order by (created_at desc);

insert into posts_by_topic (topic_id, post_id, user_id, day, username, created_at)
values (2, 1, 1, '2026-03-14', 'alina', '2026-03-14 10:00:00');

insert into posts_by_topic (topic_id, post_id, user_id, day, username, created_at)
values (2, 2, 1, '2026-03-14', 'alina', '2026-03-14 11:15:00');

insert into posts_by_topic (topic_id, post_id, user_id, day, username, created_at)
values (1, 3, 2, '2026-03-14', 'maxim', '2026-03-14 09:30:00');

insert into posts_by_topic (topic_id, post_id, user_id, day, username, created_at)
values (2, 4, 2, '2026-03-15', 'maxim', '2026-03-15 08:45:00');

insert into posts_by_topic (topic_id, post_id, user_id, day, username, created_at)
values (2, 5, 3, '2026-03-14', 'oleg', '2026-03-14 14:20:00');

insert into posts_by_topic (topic_id, post_id, user_id, day, username, created_at)
values (2, 6, 3, '2026-03-15', 'oleg', '2026-03-15 12:10:00');

select *
from posts_by_user;

select *
from posts_by_topic;

-- Запрос для task_1
select
    post_id,
    content,
    created_at
from posts_by_user
where user_id = 1;

-- Запрос для task_2
select
    post_id,
    content,
    created_at,
    username
from posts_by_user
where user_id = 1
limit 1;

-- Запрос для task_3
select
    post_id,
    content,
    created_at
from posts_by_user
where user_id = 1
  and created_at > '2026-03-14';

-- Запрос для task_4
select
    user_id,
    username,
    post_id,
    created_at
from posts_by_topic
where topic_id = 2
  and day = '2026-03-14';