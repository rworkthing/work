<bod-message-container [messages]="errorMessages"></bod-message-container>
<bod-form
  [formGroup]="addNewRestrictionFormGroup"
  rufId
  [type]="formType"
  (onSubmit)="onAddNewRestriction(isAdd)"
  (onReset)="onReset(isAdd)"
  fisStyle
>
  <bod-input-layout col="2">
    <bod-control-group
      [truncate]="false"
      [label]="translationKey + 'metadataconfig.code'"
      [forTextOnly]="true"
      [required]="true"
    >
    <div *ngIf="isEdit">
      {{ addNewRestrictionFormGroup.get('restrictionCode')?.value }}
    </div>
      <mat-form-field appearance="outline" fisStyle *ngIf="!isEdit">
        <input
          type="text"
          matInput
          fisStyle
          formControlName="restrictionCode"
          name="restrictionCode"
        />
        
        <mat-error>
         {{ getError('restrictionCode', addNewRestrictionFormGroup) | translate }}
        </mat-error> 
        <mat-error *ngIf="addNewRestrictionFormGroup.get('restrictionCode').hasError('noSpecialCharacters')">
        </mat-error>
      </mat-form-field>
    </bod-control-group>
   
    <bod-control-group
      [truncate]="false"
      [label]="translationKey + 'metadataconfig.name'"
      [forTextOnly]="true"
      [required]="true"
    >
      <mat-form-field appearance="outline" fisStyle>
        <input
          type="text"
          matInput
          fisStyle
          formControlName="restrictionName"
          name="restrictionName"
          [readonly]="isEdit"
        />
        <mat-error>
          {{ getError('restrictionName', addNewRestrictionFormGroup) | translate }}
        </mat-error>
      </mat-form-field>
    </bod-control-group>

   <bod-control-group
      [truncate]="false"
      [label]="translationKey + 'metadataconfig.description'"
      [forTextOnly]="true"
      [required]="true"
    >
      <mat-form-field appearance="outline" fisStyle>
        <input
          type="text"
          matInput
          fisStyle
          formControlName="description"
          name="description"
          [readonly]="isEdit"
        />
        <mat-error>
          {{ getError('description', addNewRestrictionFormGroup) | translate }}
        </mat-error>
      </mat-form-field>
    </bod-control-group>
  
    <bod-control-group
      [truncate]="false"
      [label]="translationKey + 'metadataconfig.exceptionValue'"
      [forTextOnly]="true"
      [required]="true"
    >
      <mat-form-field appearance="outline" fisStyle>
        <mat-select
          panelClass="fis-style"
          formControlName="exceptionValue"
          name="exceptionValue"
        >
          <mat-option
            *ngFor="let exceptionValue of exceptionValues"
            [value]="exceptionValue.value"
          >
            {{ exceptionValue.label }}
          </mat-option>
        </mat-select>
      </mat-form-field>
    </bod-control-group>
  
    <bod-control-group
      [truncate]="false"
      [label]="translationKey + 'metadataconfig.processMode'"
      [forTextOnly]="true"
      [required]="true"
    >
      <mat-form-field appearance="outline" fisStyle>
        <mat-select
          panelClass="fis-style"
          formControlName="processMode"
          name="processMode"
        >
          <mat-option
            *ngFor="let processMode of processModes"
            [value]="processMode.value"
          >
            {{ processMode.label }}
          </mat-option>
        </mat-select>
      </mat-form-field>
    </bod-control-group>
 
    <bod-control-group
      [truncate]="false"
      [label]="translationKey + 'metadataconfig.activityType'"
      [forTextOnly]="true"
      [required]="true"
    >
      <mat-form-field appearance="outline" fisStyle>
        <mat-select
          panelClass="fis-style"
          formControlName="activityType"
          name="activityType"
        >
          <mat-option
            *ngFor="let activityType of activityTypes"
            [value]="activityType.value"
          >
            {{ activityType.label }}
          </mat-option>
        </mat-select>
      </mat-form-field>
    </bod-control-group>
  </bod-input-layout>
<h1>Restriction Relationship</h1>

   <!-- Period Type Section -->
  <bod-period-type
    #periodTypeRef
    [periodTypeData]="periodTypeTableData"
    (completeDeltaChangePeriodType)="handleCompleteDeltaChangePeriodType($event)"
    (tableDirty)="onTableDirty()"
  ></bod-period-type>

</bod-form>



















import {
  ChangeDetectorRef,
  Component,
  EventEmitter,
  Input,
  OnInit,
  Output,
  ViewChild
} from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  AbstractControl,
  FormBuilder,
  FormControl,
  FormGroup,
  FormsModule,
  ReactiveFormsModule,
  UntypedFormControl,
  UntypedFormGroup,
  ValidationErrors,
  ValidatorFn,
  Validators
} from '@angular/forms';
import { TranslationKey } from '../../metadat-config/codegen-config.constant';
import { RestrictionService } from '../restriction-service';
import { MetadataService } from '../../metadat-config/metada-config.service';
import {
  BodCommonDialogService,
  BodCommonModule,
  BodCurrencyControlModule,
  BodDynamicFormModule,
  BodFormModule,
  BodFormStateService,
  BodFormTypes,
  BodPageContainerModule,
  BodTableAction,
  BodTableActionsModule,
  BodTableActionType,
  BodTableComponent,
  BodTableMetadata,
  BodTableModule,
  CommonDialogComponent,
  ControlGroupModule,
  DirectivesModule,
  EditTableAction,
  EditTableEventData,
  InlineEditOutput,
  InputLayoutModule,
  InquiryLayoutModule,
  MessageContainerModule,
  ModeOptions,
  NotificationMessage,
  NotificationMessageType,
  RowLeftAction,
  SearchFieldModule,
  SectionContainerModule
} from '@bod/common';
import { RestrictionDetailsComponent } from '../restriction-details.component';
import { MatIconModule } from '@angular/material/icon';
import { RufIconModule } from '@ruf/shell/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatTabsModule } from '@angular/material/tabs';
import { TranslateModule } from '@ngx-translate/core';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatButtonToggleModule } from '@angular/material/button-toggle';
import { MatTableDataSource } from '@angular/material/table';
import { FormUtilityService } from '../../metadat-config/form-utility.service';
import { MatDialogRef } from '@angular/material/dialog';
import { ExceptionTrigger, RestrictionList } from './add-edit-restriction.model';
import { RestrictionRelationship, PeriodTypeComponent } from './period-type/period-type.component';

@Component({
  selector: 'bod-add-edit-restriction',
  standalone: true,
  imports: [
    PeriodTypeComponent,
    InquiryLayoutModule,
    SearchFieldModule,
    MatIconModule,
    RufIconModule,
    DirectivesModule,
    MatButtonModule,
    MatSlideToggleModule,
    MatTabsModule,
    CommonModule,
    TranslateModule,
    BodPageContainerModule,
    BodTableModule,
    TranslateModule,
    BodTableActionsModule,
    FormsModule,
    InputLayoutModule,
    BodFormModule,
    ControlGroupModule,
    MatFormFieldModule,
    MatSelectModule,
    MatDatepickerModule,
    ReactiveFormsModule,
    BodDynamicFormModule,
    SectionContainerModule,
    MatInputModule,
    TranslateModule,
    MessageContainerModule,
    MatButtonToggleModule,
    BodCurrencyControlModule,
    MatDatepickerModule,
    BodCommonModule
  ],
  templateUrl: './add-edit-restriction.component.html',
  styleUrl: './add-edit-restriction.component.scss'
})
export class AddEditRestrictionComponent implements OnInit {
  public translationKey = TranslationKey;
  public addNewRestrictionFormGroup: UntypedFormGroup;
  formType: BodFormTypes = BodFormTypes.SUBMIT;

  @Input() retainedCode: string = '';
  @Input() retainedIdentifier: number = 0;
  @Input() retainedName: string = '';
  @Input() retainedDescription: string = '';

  @Input() retainedExceptionValue: string = '';
  @Input() retainedActivityType: string = '';
  @Input() retainedProcessMode: string = '';
  @Input() retainedPeriodTypeData: ExceptionTrigger[] = [];
  @Input() editResitrictionRow: RestrictionList;
  public childRestriction: any[] = [];

  @Output() apiResponse: EventEmitter<NotificationMessage[]> = new EventEmitter<
    NotificationMessage[]
  >();

  public errorMessages: NotificationMessage[] = [];
  public modeOptions: ModeOptions = { input: false, reset: false };

  @ViewChild('systemMessage', { static: true }) systemMessage: any;
  @ViewChild('periodTypeRef') periodTypeRef: PeriodTypeComponent;

  public messages: NotificationMessage[] = [];
  public message: NotificationMessage | undefined;
  private dialogRef$: MatDialogRef<CommonDialogComponent, any>;

  exceptionValues = [
    { label: 'Warning', value: 'Warning' },
    { label: 'Error', value: 'Error' },
    { label: 'Information', value: 'Information' }
  ];

  processModes = [
    { label: 'Any', value: 'Any' },
    { label: 'Automatic', value: 'Automatic' },
    { label: 'Manual', value: 'Manual' }
  ];

  activityTypes = [
    { label: 'Non Monetory', value: 'Non Monetory' },
    { label: 'Inquiry', value: 'Inquiry' },
    { label: 'Monetory', value: 'Monetory' }
  ];
  statusControl = new FormControl(null);
  public previousStatus: string | undefined;
  isAdd = true;
  isEdit = false;
  public isTableDirty = false;

  // Period Type table data
  public periodTypeTableData: ExceptionTrigger[] = [];

  constructor(
    private changeDetectorRef: ChangeDetectorRef,
    private bodFormStateService: BodFormStateService,
    public RestrictionService: RestrictionService,
    private fb: FormBuilder,
    private bodCommonDialogService: BodCommonDialogService,
    private metadataService: MetadataService
  ) { }

  ngOnInit() {
    this.initForm();
    this.loadDropDownData(() => {
      if (this.editResitrictionRow) {
        this.restrictionForm(this.editResitrictionRow);
      }
    });
    this.metadataService.retrieveAll().subscribe((response: any) => {
      const firstStatus = response?.data?.[0]?.MetadataStatus;
      const statusToSet = firstStatus || 'NEW';
      this.statusControl.setValue(statusToSet);
      this.previousStatus = statusToSet;
    });
  }

  private childRestrictionMap: { [id: number]: string } = {};

  loadDropDownData(callback?: () => void): void {
    this.RestrictionService.getRestrictions().subscribe(data => {
      this.childRestriction = data.map((item: any) => ({
        label: item.code,
        value: item.identifier
      }));
      // Build a map for quick lookup
      this.childRestrictionMap = {};
      data.forEach((item: any) => {
        this.childRestrictionMap[item.identifier] = item.code;
      });
      if (callback) callback();
    });
  }

  private initForm(): void {
    this.addNewRestrictionFormGroup = this.fb.group({
      restrictionCode: new UntypedFormControl('', [
        Validators.required,
        this.noSpecialCharactersValidator(),
        this.maxLengthValidator(32)
      ]),
      restrictionIdentifier: [{ value: '', disabled: true }],
      restrictionName: new UntypedFormControl('', [
        Validators.required,
        this.maxLengthValidator(120)
      ]),
      description: new UntypedFormControl('', [
        Validators.required,
        this.noSpecialCharactersValidator(),
        this.maxLengthValidator(254)
      ]),
      exceptionValue: new UntypedFormControl('', [Validators.required]),
      processMode: new UntypedFormControl('', [Validators.required]),
      activityType: new UntypedFormControl('', [Validators.required])
    });
  }

  noSpecialCharactersValidator(): ValidatorFn {
    return (control: AbstractControl): { [key: string]: any } | null => {
      const forbidden = /[^a-zA-Z0-9]/.test(control.value);
      return forbidden
        ? { noSpecialCharacters: { value: control.value } }
        : null;
    };
  }

  maxLengthValidator(maxLength: number): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const value = control.value;

      if (value === null || value === undefined || value === '') {
        return null;
      }

      const stringValue = value.toString();

      return stringValue.length > maxLength
        ? { maxLength: 'Value exceeds allowed digit limit' }
        : null;
    };
  }

  identifierSearch(field: string): Promise<void> {
    return new Promise((resolve, reject) => {
      this.metadataService.idfrSearch().subscribe(
        (response: string) => {
          if (field === 'restrictionIdentifier') {
            this.addNewRestrictionFormGroup.controls['restrictionIdentifier'].setValue(response);
          }
          this.addNewRestrictionFormGroup.markAsDirty();
          resolve();
        },
        error => {
          console.error('Error:', error);
          reject(error);
        }
      );
    });
  }

  public getError(control: string, formGroup: UntypedFormGroup): string {
    if (formGroup) {
      const fc: AbstractControl = formGroup.get(control);
      if (fc && fc.errors && fc.touched) {
        return FormUtilityService.getCommonFCErrorMsg(fc);
      }
    }
  }

  public onTableDirty(): void {
    this.isTableDirty = true;
    this.addNewRestrictionFormGroup.markAsDirty();
  }

  // Handle period type table data changes
  public completeDeltaPeriodTypeData: any;
  handleCompleteDeltaChangePeriodType(data: any) {
    this.completeDeltaPeriodTypeData = data;

  }

  onAddNewRestriction(isAdd: boolean) {
    const promises = [];

    if (isAdd) {
      promises.push(this.identifierSearch('restrictionIdentifier'));
    }

    Promise.all(promises)
      .then(() => {
        this.submitForm(isAdd);
      })
      .catch(error => {
        console.error('Error during identifier search:', error);
      });
  }

  submitForm(isAdd: boolean) {
    this.errorMessages = [];

    if (this.addNewRestrictionFormGroup.invalid) {
      this.addNewRestrictionFormGroup.markAllAsTouched();
      const missingFields = this.getInvalidRequiredFields(this.addNewRestrictionFormGroup);
      this.handleError(
        {
          errorCode: 'FORM_INVALID',
          status: 400,
          missingFields
        },
        isAdd
      );
      return;
    }

    const formValue = this.addNewRestrictionFormGroup.getRawValue();
    this.addNewRestrictionFormGroup.controls['restrictionIdentifier'].enable();

    // Get product type data from metadata service
    const productTypeKeys = this.metadataService.getProductTypeKeys();
    const productTypeValues = this.metadataService.getProductTypeValues();

    // Get period type data
    const periodTypeList = this.periodTypeRef?.getCurrentTablePeriodType() || [];

    // --- ADD THIS BLOCK ---
   
    // Check if any row has empty periodType
    const hasEmptyPeriodType = periodTypeList.some(pt => !pt.childRestriction || pt.childRestriction.trim() === '');
    if (hasEmptyPeriodType) {
      this.handleError(
        {
          errorCode: 'PERIOD_TYPE_REQUIRED',
          status: 412
        },
        isAdd
      );
      return;
    }
    // Check for duplicate periodType values
    const periodTypes = periodTypeList.map(pt => pt.childRestriction?.trim());
    const duplicates = periodTypes.filter((type, idx, arr) => type && arr.indexOf(type) !== idx && arr.lastIndexOf(type) === idx);
    if (duplicates.length > 0) {
      this.handleError(
        {
          errorCode: 'DUPLICATE_PERIOD_TYPE',
          status: 413,
          duplicateNames: duplicates.join(', ')
        },
        isAdd
      );
      return;
    }
    // --- END BLOCK ---

    // Build productElementExceptionRltnList
    const productElementExceptionRltnList = productTypeKeys.map((code, index) => ({
      productTypeIdentifier: productTypeValues[index],
      exceptionIdentifier: formValue.restrictionIdentifier,
      exceptionValue: formValue.exceptionValue,
      processMode: formValue.processMode,
      exceptionCode: formValue.restrictionCode,
      activityType: formValue.activityType
    }));

    const productElementExceptionTriggerList = periodTypeList.map(period => {
      // Find the dropdown item matching the childRestriction label
      const dropdownItem = this.childRestriction.find(
        item => item.label === period.childRestriction
      );
      return {
        productTypeIdentifier: productTypeValues[0], // or map for each product type if needed
        exceptionParentIdentifier: formValue.restrictionIdentifier,
        exceptionChildIdentifier: dropdownItem ? dropdownItem.value : null, // Use id from dropdown data
        exceptionTriggerExclude: period.isExclude ? 'Y' : 'N'
      };
    });

    // Build restrictionDetailList
    const restrictionDetailList = [{
      exceptionDefinition: {
        identifier: formValue.restrictionIdentifier,
        code: formValue.restrictionCode,
        name: formValue.restrictionName,
        description: formValue.description,
        classificationType: formValue.exceptionValue // Store exceptionValue in classificationType
      },
      productElementExceptionRltnList,
      productElementExceptionTriggerList
    }];

    // Build productTypeList
    const productTypeList = productTypeKeys.map((code, index) => ({
      identifier: productTypeValues[index],
      code: code
    }));

    // Final request object
    const restrictionData = {
      metadataType: 'Restriction',
      restrictionDetailList,
      productTypeList
    };
    const serviceCall = isAdd
      ? this.RestrictionService.saveRestriction(restrictionData)
      : this.RestrictionService.updateRestriction(restrictionData);

    serviceCall.subscribe({
      next: resp => this.successResponse(resp, restrictionData, isAdd),
      error: (err: NotificationMessage[]) => this.handleError(err, isAdd)
    });

    this.addNewRestrictionFormGroup.controls['restrictionIdentifier'].disable();
  }


  private getInvalidRequiredFields(formGroup: FormGroup): string[] {
    const invalidFields: string[] = [];

    Object.keys(formGroup.controls).forEach(key => {
      const control = formGroup.get(key);
      if (control && control.errors?.['required']) {
        invalidFields.push(key);
      }
    });

    return invalidFields;
  }

  private successResponse(resp, restrictionData, isAdd) {
    const restrictionCode = restrictionData.restrictionDetailList[0].exceptionDefinition.code;
    const SuccessMsg = isAdd
      ? `${restrictionCode} Added successfully`
      : `${restrictionCode} Updated successfully`;
    this.apiResponse.emit({ ...restrictionData, SuccessMsg });
  }

  private handleError(error: any, isAdd: boolean) {
    let errorMsg = '';

    if (error.errorCode === 'FORM_INVALID' || error.status === 400) {
      if (error.missingFields?.length) {
        errorMsg = `Please fill the required fields.`;
      } else {
        errorMsg = 'Please fill the required fields.';
      }
    } else if (error.errorCode === 'PERIOD_TYPE_REQUIRED') {
      errorMsg = 'Child Restriction required.';
    } else if (error.errorCode === 'DUPLICATE_PERIOD_TYPE') {
      errorMsg = 'Duplicate Child Restriction found: ' +
        (error.duplicateNames ? error.duplicateNames : '');
    } else if (error.error?.errorCode === "MBP_SDK_BUS_ERR_005") {
      errorMsg = 'Code already exists.';
    } else if (error.error?.errorCode === "MBP_SDK_BUS_ERR_004") {
      errorMsg = error.error?.errorDescription || 'Code already exists.';
    } else if (error.error?.errorCode === "MBP_SDK_BUS_ERR_048") {
      errorMsg = error.error?.errorDescription || 'This Metadata cannot be created.';
    } else {
      errorMsg = 'Unknown error occurred.';
    }

    this.message = {
      code: error.errorCode,
      text: errorMsg,
      type: NotificationMessageType.ERROR
    };
    this.errorMessages.push(this.message);

    // Auto-remove error messages after 10 seconds
    setTimeout(() => {
      this.errorMessages = this.errorMessages.filter(msg => msg.text !== errorMsg);
    }, 10000);
  }

  onReset(isAdd: boolean): void {
    const isEditMode = this.isEdit;

    // Reset error messages
    this.errorMessages = [];

    // Reset the form
    this.addNewRestrictionFormGroup.reset();
    this.addNewRestrictionFormGroup.markAsPristine();
    this.addNewRestrictionFormGroup.markAsUntouched();

    // Reset table dirty state
    this.isTableDirty = false;

    if (isEditMode) {
      // Restore retained values for edit mode
      this.addNewRestrictionFormGroup.get('restrictionCode')?.setValue(this.retainedCode);
      this.addNewRestrictionFormGroup.get('restrictionCode')?.disable();
      this.addNewRestrictionFormGroup.get('restrictionIdentifier')?.setValue(this.retainedIdentifier);
      this.addNewRestrictionFormGroup.get('restrictionIdentifier')?.disable();
      this.addNewRestrictionFormGroup.get('restrictionName')?.setValue(this.retainedName);
      this.addNewRestrictionFormGroup.get('description')?.setValue(this.retainedDescription);
      this.addNewRestrictionFormGroup.get('classificationtype')?.setValue(this.retainedExceptionValue);
      this.addNewRestrictionFormGroup.get('activityType')?.setValue(this.retainedActivityType);
      this.addNewRestrictionFormGroup.get('processMode')?.setValue(this.retainedProcessMode);

      // Reset period type data to retained values
      this.periodTypeTableData = [...this.retainedPeriodTypeData];

      // Reset the period type table if it exists
      if (this.periodTypeRef) {
        this.periodTypeRef.reset();
      }
    } else {
      this.addNewRestrictionFormGroup.get('restrictionCode')?.enable();
      this.addNewRestrictionFormGroup.get('restrictionIdentifier')?.enable();

      // Clear period type data for new additions
      this.periodTypeTableData = [];
    }

    this.changeDetectorRef.detectChanges();
  }

  private mapPeriodTypeData(exceptionTriggers: ExceptionTrigger[]): any[] {
    return exceptionTriggers.map(trigger => {
      // Find the dropdown item by identifier (number or string)
      const dropdownItem = this.childRestriction.find(
        item => String(item.value) === String(trigger.exceptionChildIdentifier)
      );
      const code = dropdownItem ? dropdownItem.label : trigger.exceptionChildIdentifier;
      return {
        childRestriction: dropdownItem ? dropdownItem.label : String(trigger.exceptionChildIdentifier), // for display
        childRestrictionId: dropdownItem ? dropdownItem.value : trigger.exceptionChildIdentifier,      // for API 
        isExclude: trigger.exceptionTriggerExclude === 'Y'
      };
    });
  }

  private restrictionForm(element: RestrictionList): void {
    this.isAdd = false;
    this.isEdit = true;

    // Store retained values
    this.retainedCode = element.code || '';
    this.retainedIdentifier = element.identifier || 0;
    this.retainedName = element.name || '';
    this.retainedDescription = element.description || '';
    this.retainedExceptionValue = element.exceptionValue || '';
    this.retainedActivityType = element.activityType || '';
    this.retainedActivityType = element.activityType || '';

    this.retainedPeriodTypeData = element.exceptionTrigger
      ? element.exceptionTrigger.map((item) => ({
        productTypeIdentifier: item.productTypeIdentifier,
        exceptionParentIdentifier: item.exceptionParentIdentifier,
        exceptionChildIdentifier: item.exceptionChildIdentifier,
        exceptionTriggerExclude: item.exceptionTriggerExclude
      }))
      : [];

    console.log('retainedPeriodTypeData:', JSON.stringify(this.retainedPeriodTypeData, null, 2));

    this.addNewRestrictionFormGroup.patchValue({
      restrictionIdentifier: element.identifier,
      restrictionCode: element.code,
      restrictionName: element.name, // Use description for name if that's your field mapping
      exceptionValue: element.classificationType, // Use classificationType for exceptionValue
      activityType: element.exceptionRltn?.[0]?.activityType || '', // Get from first exceptionRltn
      processMode: element.exceptionRltn?.[0]?.processMode || '', // Get from first exceptionRltn
      description: element.description // If you have a description field in your form
    });

    // Set period type data
    this.periodTypeTableData = this.mapPeriodTypeData(this.retainedPeriodTypeData);

    // Disable code field in edit mode
    this.addNewRestrictionFormGroup.get('restrictionCode')?.disable();
  }
}






























export interface RestrictionList {
  identifier?: number;
  code?: string;
  name?: string;
  description?: string;
  exceptionValue?: string;
  processMode?: string;
  activityType?: string;
  restrictionRelationshipList?: RestrictionRelationship[];
  restrictionInquiry?: RestrictionInquiry[];
  exceptionTrigger?:ExceptionTrigger[];
  classificationType?:string;
    exceptionRltn?: ExceptionRltn[]; // <-- Added this line

  
  
}
export interface ExceptionRltn {
  activityType?: string;
  exceptionCode?: string | null;
  exceptionIdentifier?: number;
  exceptionValue?: string;
  processMode?: string;
  productTypeIdentifier?: number;
}
export interface ExceptionTrigger {
  productTypeIdentifier?: number;
  exceptionParentIdentifier?: number;
  exceptionChildIdentifier?: number | string;
  exceptionTriggerExclude?: string;
}

export interface RestrictionInquiry {
  id: number;
  label: string;
  value: string;
}

export interface RestrictionRelationship {
  childRestriction: string;
  isExclude: boolean;
}

export interface RestrictionData {
  metadataType: string;
  restrictionList: RestrictionListItem[];
  productTypeList: ProductType[];
}

export interface RestrictionListItem {
  restriction: Restriction;
  periodTypeList?: RestrictionRelationship[];
}

export interface Restriction {
  identifier: number;
  code: string;
  name: string;
  systemRestriction?: string;
  classificationType: string;
  ruleCheck: string;
}

export interface ProductType {
  identifier: number;
  code: string;
}























