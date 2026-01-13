import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../services/api.service';
import { AuthService } from '../../services/auth.service';
import { TriageResult, ClinicianReviewPayload } from '../../types';
import { firstValueFrom } from 'rxjs';

interface TriageSummary {
  encounterId: string;
  acuity: string;
  emergencyFlag: boolean;
  confidenceScore?: number | null;
  summaryForClinician?: string;
  safetyWarnings?: string;
  rationaleInternal?: string;
  clarifyingQuestions?: string;
  triageResult?: TriageResult;
}

@Component({
  selector: 'app-clinician-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './clinician-dashboard.component.html',
  styleUrls: ['./clinician-dashboard.component.scss'],
})
export class ClinicianDashboardComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);

  triageSummaries: TriageSummary[] = [];
  loading = false;
  error: string | null = null;
  selectedEncounterId: string | null = null;
  reviewDecision: string = 'approved';
  reviewNotes: string = '';
  reviewOverrideFlag: boolean = false;
  reviewOverrideReason: string = '';
  submittingReview = false;

  async ngOnInit() {
    // TODO: Fetch encounters that need review from API
    // For now, this is a placeholder - in production, you'd fetch from an endpoint like:
    // GET /api/encounters?status=triaged
    this.loading = true;
    try {
      // Placeholder - replace with actual API call when endpoint is available
      // const encounters = await firstValueFrom(this.api.getEncountersByStatus('triaged'));
      // this.triageSummaries = encounters.map(e => ({ ...e }));
    } catch (err: any) {
      this.error = err?.message || 'Failed to load triage summaries.';
    } finally {
      this.loading = false;
    }
  }

  selectEncounter(encounterId: string) {
    this.selectedEncounterId = encounterId;
    const summary = this.triageSummaries.find(s => s.encounterId === encounterId);
    if (summary?.triageResult) {
      // Pre-populate review fields if triage result exists
    }
  }

  async submitReview(encounterId: string) {
    if (!this.selectedEncounterId || this.selectedEncounterId !== encounterId) {
      return;
    }

    const reviewerId = this.auth.getUserId() || 'unknown';
    if (!reviewerId) {
      this.error = 'User ID not available.';
      return;
    }

    this.submittingReview = true;
    this.error = null;

    try {
      const payload: ClinicianReviewPayload = {
        decision: this.reviewDecision,
        overrideFlag: this.reviewOverrideFlag,
        overrideReason: this.reviewOverrideFlag ? this.reviewOverrideReason : undefined,
        notes: this.reviewNotes || undefined,
        reviewerId: reviewerId,
      };

      await firstValueFrom(this.api.clinicianReview(encounterId, payload));
      
      // Remove from list after successful review
      this.triageSummaries = this.triageSummaries.filter(s => s.encounterId !== encounterId);
      this.selectedEncounterId = null;
      this.resetReviewForm();
    } catch (err: any) {
      this.error = err?.message || 'Failed to submit review.';
    } finally {
      this.submittingReview = false;
    }
  }

  private resetReviewForm() {
    this.reviewDecision = 'approved';
    this.reviewNotes = '';
    this.reviewOverrideFlag = false;
    this.reviewOverrideReason = '';
  }
}

