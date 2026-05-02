import { pgTable, serial, text, timestamp, varchar } from 'drizzle-orm/pg-core';

export const libraries = pgTable('libraries', {
  id: serial().primaryKey(),
  name: text().notNull(),
  address: text().notNull(),
  city: text().notNull(),
  state: text().notNull(),
  zip: text().notNull(),
  phone: text().notNull(),
  img: text().notNull(),
});

export const users = pgTable('users', {
  id: serial().primaryKey(),
  netlifyId: varchar('netlify_id', { length: 255 }).notNull().unique(),
  email: varchar({ length: 255 }).notNull().unique(),
  createdAt: timestamp('created_at').defaultNow(),
});
