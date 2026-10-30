DROP TABLE IF EXISTS movie_categories   CASCADE;
DROP TABLE IF EXISTS categories         CASCADE;
DROP TABLE IF EXISTS payments           CASCADE;
DROP TABLE IF EXISTS movie_views        CASCADE;
DROP TABLE IF EXISTS user_subscriptions CASCADE;
DROP TABLE IF EXISTS movie_genres       CASCADE;
DROP TABLE IF EXISTS subscriptions      CASCADE;
DROP TABLE IF EXISTS genres             CASCADE;
DROP TABLE IF EXISTS movies             CASCADE;
DROP TABLE IF EXISTS users              CASCADE;

CREATE TABLE users (
    user_id       bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email         varchar(255) NOT NULL UNIQUE,
    full_name     varchar(255) NOT NULL,
    registered_at timestamptz  NOT NULL DEFAULT now()
);

CREATE TABLE movies (
    movie_id      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title         varchar(255) NOT NULL,
    release_year  smallint     NOT NULL CHECK (release_year BETWEEN 1900 AND 2100),
    duration_min  smallint     NOT NULL CHECK (duration_min > 0),
    rating        numeric(3,1) CHECK (rating BETWEEN 0 AND 10),
    created_at    timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_movies_title_year UNIQUE (title, release_year)
);

CREATE TABLE genres (
    genre_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name     varchar(100) NOT NULL UNIQUE
);

CREATE TABLE movie_genres (
    movie_id bigint NOT NULL,
    genre_id bigint NOT NULL,
    CONSTRAINT pk_movie_genres PRIMARY KEY (movie_id, genre_id),
    CONSTRAINT fk_movie_genres_movie FOREIGN KEY (movie_id)
        REFERENCES movies(movie_id) ON DELETE CASCADE,
    CONSTRAINT fk_movie_genres_genre FOREIGN KEY (genre_id)
        REFERENCES genres(genre_id) ON DELETE RESTRICT
);

CREATE TABLE subscriptions (
    subscription_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name            varchar(100)  NOT NULL UNIQUE,
    price           numeric(10,2) NOT NULL CHECK (price > 0),
    duration_days   integer       NOT NULL CHECK (duration_days > 0),
    is_active       boolean       NOT NULL DEFAULT true
);

CREATE TABLE user_subscriptions (
    user_id         bigint NOT NULL,
    subscription_id bigint NOT NULL,
    start_date      date   NOT NULL DEFAULT current_date,
    end_date        date   NOT NULL,
    CONSTRAINT pk_user_subscriptions PRIMARY KEY (user_id, subscription_id, start_date),
    CONSTRAINT chk_user_subs_dates CHECK (end_date > start_date),
    CONSTRAINT fk_user_subs_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_user_subs_sub FOREIGN KEY (subscription_id)
        REFERENCES subscriptions(subscription_id) ON DELETE RESTRICT
);

CREATE TABLE movie_views (
    view_id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id    bigint       NOT NULL,
    movie_id   bigint       NOT NULL,
    watched_at timestamptz  NOT NULL DEFAULT now(),
    progress   smallint     NOT NULL DEFAULT 0 CHECK (progress BETWEEN 0 AND 100),
    CONSTRAINT fk_movie_views_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_movie_views_movie FOREIGN KEY (movie_id)
        REFERENCES movies(movie_id) ON DELETE RESTRICT
);

CREATE TABLE payments (
    payment_id      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id         bigint        NOT NULL,
    subscription_id bigint        NOT NULL,
    amount          numeric(10,2) NOT NULL CHECK (amount > 0),
    paid_at         timestamptz   NOT NULL DEFAULT now(),
    status          varchar(20)   NOT NULL DEFAULT 'SUCCESS'
                    CHECK (status IN ('PENDING','SUCCESS','FAILED','REFUNDED')),
    CONSTRAINT fk_payments_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_payments_sub FOREIGN KEY (subscription_id)
        REFERENCES subscriptions(subscription_id) ON DELETE RESTRICT
);

CREATE TABLE categories (
    category_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        varchar(100) NOT NULL UNIQUE
);

CREATE TABLE movie_categories (
    movie_id    bigint NOT NULL,
    category_id bigint NOT NULL,
    CONSTRAINT pk_movie_categories PRIMARY KEY (movie_id, category_id),
    CONSTRAINT fk_movie_categories_movie FOREIGN KEY (movie_id)
        REFERENCES movies(movie_id) ON DELETE CASCADE,
    CONSTRAINT fk_movie_categories_category FOREIGN KEY (category_id)
        REFERENCES categories(category_id) ON DELETE RESTRICT
);
