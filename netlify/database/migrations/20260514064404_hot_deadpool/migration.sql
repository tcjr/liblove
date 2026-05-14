CREATE TABLE "visits" (
	"id" serial PRIMARY KEY,
	"user_id" integer NOT NULL,
	"library_id" integer NOT NULL,
	"visited_at" timestamp with time zone DEFAULT now(),
	CONSTRAINT "visits_user_id_library_id_unique" UNIQUE("user_id","library_id")
);
--> statement-breakpoint
ALTER TABLE "libraries" ALTER COLUMN "metro" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "visits" ADD CONSTRAINT "visits_user_id_users_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id");--> statement-breakpoint
ALTER TABLE "visits" ADD CONSTRAINT "visits_library_id_libraries_id_fkey" FOREIGN KEY ("library_id") REFERENCES "libraries"("id");