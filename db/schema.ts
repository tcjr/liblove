import {
  doublePrecision,
  integer,
  pgTable,
  serial,
  text,
  timestamp,
  unique,
  varchar,
} from 'drizzle-orm/pg-core';

export const libraries = pgTable('libraries', {
  id: serial().primaryKey(),
  name: text().notNull(),
  address: text().notNull(),
  city: text().notNull(),
  state: text().notNull(),
  zip: text().notNull(),
  phone: text().notNull(),
  img: text().notNull(),
  lat: doublePrecision(),
  lon: doublePrecision(),
  metro: text('metro').notNull(),
});

export const users = pgTable('users', {
  id: serial().primaryKey(),
  netlifyId: varchar('netlify_id', { length: 255 }).notNull().unique(),
  email: varchar({ length: 255 }).notNull().unique(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
});

export const visits = pgTable(
  'visits',
  {
    id: serial().primaryKey(),
    userId: integer('user_id')
      .references(() => users.id)
      .notNull(),
    libraryId: integer('library_id')
      .references(() => libraries.id)
      .notNull(),
    visitedAt: timestamp('visited_at', { withTimezone: true }).defaultNow(),
  },
  (t) => [unique().on(t.userId, t.libraryId)],
);
