import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-clinician-dashboard',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './clinician-dashboard.component.html',
  styleUrls: ['./clinician-dashboard.component.scss'],
})
export class ClinicianDashboardComponent {
  // Placeholder list; in production pull from gateway with authZ.
  triageSummaries = [
    {
      encounterId: 'demo-enc-001',
      acuity: 'Emergent',
      emergencyFlag: true,
      summary: 'Acuity: Emergent; Emergency flag: true; Key symptoms: chest pain, dyspnea; Rationale: Chest pain with breathing difficulty.; AI-generated summary for clinician review. Not a diagnosis.',
    },
  ];
}

