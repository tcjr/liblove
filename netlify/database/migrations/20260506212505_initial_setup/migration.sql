CREATE TABLE "libraries" (
	"id" serial PRIMARY KEY,
	"name" text NOT NULL,
	"address" text NOT NULL,
	"city" text NOT NULL,
	"state" text NOT NULL,
	"zip" text NOT NULL,
	"phone" text NOT NULL,
	"img" text NOT NULL,
	"lat" double precision,
	"lon" double precision
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" serial PRIMARY KEY,
	"netlify_id" varchar(255) NOT NULL UNIQUE,
	"email" varchar(255) NOT NULL UNIQUE,
	"created_at" timestamp with time zone DEFAULT now()
);
