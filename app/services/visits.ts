import type Owner from '@ember/owner';
import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import type { Visit } from '#app/data/models.ts';

const LOCAL_STORAGE_KEY = 'liblove:visits';

interface LocalVisit {
  id: string;
  libraryId: string;
  visitedAt: string | Date;
}

export default class VisitsService extends Service {
  @tracked records: Visit[] = [];

  constructor(owner: Owner) {
    super(owner);
    this.loadFromLocalStorage();
  }

  private loadFromLocalStorage() {
    try {
      const data = localStorage.getItem(LOCAL_STORAGE_KEY);
      if (data) {
        const parsed = JSON.parse(data) as LocalVisit[];
        this.records = parsed.map((v) => ({
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
      localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(this.records));
    } catch (e) {
      console.error('Failed to save visits to localStorage:', e);
    }
  }

  addVisit(libraryId: string, visitedAt: Date) {
    const existingIndex = this.records.findIndex(
      (v) => v.libraryId === libraryId
    );
    const newVisit: Visit = {
      id: crypto.randomUUID(),
      libraryId,
      visitedAt,
    };

    if (existingIndex > -1) {
      const updated = [...this.records];
      updated[existingIndex] = newVisit;
      this.records = updated;
    } else {
      this.records = [...this.records, newVisit];
    }
    this.saveToLocalStorage();
  }

  removeVisit(visitId: string) {
    this.records = this.records.filter((v) => v.id !== visitId);
    this.saveToLocalStorage();
  }
}
