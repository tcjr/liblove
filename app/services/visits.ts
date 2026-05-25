import type Owner from '@ember/owner';
import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import type { Visit } from '#app/data/models.ts';

const LOCAL_STORAGE_KEY = 'liblove:library-visits';

interface LibraryVisitData {
  id: string;
  libraryId: string;
  visitedAt: string | Date;
}

export default class VisitsService extends Service {
  @tracked libraryVisits: Visit[] = [];

  constructor(owner: Owner) {
    super(owner);
    this.loadFromLocalStorage();
  }

  private loadFromLocalStorage() {
    try {
      const data = localStorage.getItem(LOCAL_STORAGE_KEY);
      if (data) {
        const parsed = JSON.parse(data) as LibraryVisitData[];
        this.libraryVisits = parsed.map((v) => ({
          id: v.id,
          libraryId: v.libraryId,
          visitedAt: new Date(v.visitedAt),
        }));
      }
    } catch (e) {
      console.error('Failed to load visits from localStorage:', e);
    }
  }

  private saveToLocalStorage() {
    try {
      localStorage.setItem(
        LOCAL_STORAGE_KEY,
        JSON.stringify(this.libraryVisits)
      );
    } catch (e) {
      console.error('Failed to save visits to localStorage:', e);
    }
  }

  addLibraryVisit(libraryId: string, visitedAt: Date) {
    const existingIndex = this.libraryVisits.findIndex(
      (v) => v.libraryId === libraryId
    );
    const newVisit: Visit = {
      id: libraryId,
      libraryId,
      visitedAt,
    };

    if (existingIndex > -1) {
      const updated = [...this.libraryVisits];
      updated[existingIndex] = newVisit;
      this.libraryVisits = updated;
    } else {
      this.libraryVisits = [...this.libraryVisits, newVisit];
    }
    this.saveToLocalStorage();
  }

  removeLibraryVisit(visitId: string) {
    this.libraryVisits = this.libraryVisits.filter((v) => v.id !== visitId);
    this.saveToLocalStorage();
  }
}
