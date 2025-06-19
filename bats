import { AfterViewInit, Component, EventEmitter, Input, OnChanges, OnDestroy, OnInit, Output, SimpleChanges, ViewChild } from '@angular/core';
import { FormsModule, ReactiveFormsModule, UntypedFormBuilder, UntypedFormControl, UntypedFormGroup, Validators } from '@angular/forms';
import { MatTableDataSource, MatTableModule } from '@angular/material/table';
import {
  BodAutoCompleteModule,
  BodCommonModule,
  BodConfirmAlertDialogsService,
  BodConfirmDialogModel,
  BodCurrencyControlModule,
  BodDynamicFormModule,
  BodFormModule,
  BodFormStateService,
  BodPageContainerModule,
  BodSearchFieldData,
  BodTableAction,
  BodTableActionsModule,
  BodTableActionType,
  BodTableComponent,
  BodTableMetadata,
  BodTableModule,
  Column,
  ColumnType,
  ControlGroupModule,
  DirectivesModule,
  InlineEditOutput,
  InputLayoutModule,
  InquiryLayoutModule,
  MaxLengthStrategy,
  MessageContainerModule,
  ModeOptions,
  NotificationMessage,
  NotificationMessageType,
  PageAction,
  PageMode,
  RowLeftAction,
  SearchFieldModule,
  SectionContainerModule,
  SingleRowEdit
} from '@bod/common';
import { HttpClient } from '@angular/common/http';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { CommonModule } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatTabsModule } from '@angular/material/tabs';
import { MatButtonModule } from '@angular/material/button';
import { MatButtonToggleModule } from '@angular/material/button-toggle';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatIconModule } from '@angular/material/icon';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { RufIconModule } from '@ruf/shell/icon';
import { Subscription, take } from 'rxjs';
import { TranslationKey } from '../../metadat-config/codegen-config.constant';
import { TransactionTypeService } from '../transaction-type.service';
import { MatDialog } from '@angular/material/dialog';
import { ChannelsMultiselectTableComponent } from './channels-multiselect-table/channels-multiselect-table.component';
import { ChannelTable, CounterTable } from '../transaction-type.model';
import { ChannelsMultiselectDialogComponent } from './channels-multiselect-dialog/channels-multiselect-dialog.component';
import { CountersMultiselectTableComponent } from './counters-multiselect-table/counters-multiselect-table.component';
import { CountersMultiselectDialogComponent } from './counters-multiselect-dialog/counters-multiselect-dialog.component';
import { ConditionsMultiselectTableComponent } from './conditions-multiselect-table/conditions-multiselect-table.component';
import { ConditionsMultiselectDialogComponent } from './conditions-multiselect-dialog/conditions-multiselect-dialog.component';
import { ConditionTable } from '../transaction-type.model';
import { RestrictionsMultiselectTableComponent } from './restrictions-multiselect-table/restrictions-multiselect-table.component';
import { RestrictionsMultiselectDialogComponent } from './restrictions-multiselect-dialog/restrictions-multiselect-dialog.component';
import { RestrictionTable } from '../transaction-type.model';



@Component({
  selector: 'bod-channels-main-table',
  standalone: true,
  imports: [
    RestrictionsMultiselectTableComponent,
    RestrictionsMultiselectDialogComponent,
    ConditionsMultiselectTableComponent,
    ConditionsMultiselectDialogComponent,
    CountersMultiselectTableComponent,
    CountersMultiselectDialogComponent,
    ChannelsMultiselectTableComponent,
    ChannelsMultiselectDialogComponent,
    BodTableModule,
    TranslateModule,
    MatTableModule,
    MatTabsModule,
    BodTableActionsModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    CommonModule,
    InquiryLayoutModule,
    SearchFieldModule,
    MatIconModule,
    RufIconModule,
    ControlGroupModule,
    ReactiveFormsModule,
    MessageContainerModule,
    DirectivesModule,
    MatButtonModule,
    MatSlideToggleModule,
    BodPageContainerModule,
    FormsModule,
    InputLayoutModule,
    BodFormModule,
    BodDynamicFormModule,
    SectionContainerModule,
    MatButtonToggleModule,
    BodCurrencyControlModule,
    MatDatepickerModule,
    BodCommonModule
  ],
  templateUrl: './channels-main-table.component.html',
  styleUrl: './channels-main-table.component.scss'
})
export class ChannelsMainTableComponent implements OnInit, OnDestroy, OnChanges, AfterViewInit {
  public counterMap: { [key: number]: CounterTable[] } = {}; // Add this line
  public conditionMap: { [key: number]: ConditionTable[] } = {};
  public restrictionMap: { [key: number]: RestrictionTable[] } = {}; // Add this line

  private subscriptions: Subscription = new Subscription();
  public messages: NotificationMessage[] = [];
  public modeOptions: ModeOptions = { input: false, reset: false };
  public modeOptionsSimple = this.modeOptions;
  selectedTabIndex = 0;
  showEdit = true;
  public lastModifiedIndex: number;
  public tableRefArray: any[] = [];
  public showChannelSearchForm = false;
  public formStatus = false;


  @ViewChild('simpleEditTableRef', { static: false })
  simpleEditTableRef: BodTableComponent;

  public pageMode = PageMode.INQUIRY;
  public pageModeSimple = this.pageMode;
  private dataForReset: ChannelTable[] = [];
  selectedStrategy: MaxLengthStrategy = MaxLengthStrategy.exceedWithError;
  public translationKey = TranslationKey;
  public showActionsForSimple: boolean = false;

  @Output() tableDirty = new EventEmitter<boolean>();
  @Output() completeDeltaChange = new EventEmitter<any>();
  @Output() channelDetails = new EventEmitter<any>();
  @Input() channelData: ChannelTable[] = [];
  // Counter-related properties
  @Output() counterDetails = new EventEmitter<any[]>(); // Add this line
  @Input() counterData: CounterTable[] = [];
  @Output() conditionDetails = new EventEmitter<any[]>(); // Add this line
  @Input() conditionData: ConditionTable[] = [];
  @Output() restrictionDetails = new EventEmitter<any[]>(); // Add this line
  @Input() restrictionData: RestrictionTable[] = [];


  emitCompleteDelta() {
    const currentData = this.getCurrentTableData();
    const allCounters = this.getAllCountersWithChannelIdentifier();
    const allConditions = this.getAllConditionsWithChannelIdentifier();
    const allRestrictions = this.getAllRestrictionsWithChannelIdentifier();
    console.log('[ChannelsMainTableComponent] Emitting CompleteDelta:', {
      channels: currentData,
      counters: allCounters,
      conditions: allConditions,
      restrictions: allRestrictions
    });
    this.completeDeltaChange.emit({
      channels: currentData,
      counters: allCounters,
      conditions: allConditions,
      restrictions: allRestrictions
    });
  }



  // @Input() set channelData(data: ChannelTable[]) {
  //   this.dataWithSimpleEdit = data || [];
  //   this.tableWithSimpleEdit.datasource.data = this.dataWithSimpleEdit;
  //   console.log("dataWithSimpleEdit: ", this.dataWithSimpleEdit);
  // }
  ngOnChanges(changes: SimpleChanges) {
    if (changes['channelData']) {
      // Update your table data source
      this.dataWithSimpleEdit = this.channelData || [];
      this.tableWithSimpleEdit.datasource.data = [...(this.channelData || [])];
    }
  }
  public selectedRowCounters: CounterTable[] = [];
  public selectedCounterData: any[] = [];

  public selectedRowConditions: ConditionTable[] = [];
  public selectedConditionData: any[] = [];

  public selectedRowRestrictions: RestrictionTable[] = [];
  public selectedRestrictionData: any[] = [];

  public restrictionsTableMetadata: BodTableMetadata = {
    title: 'Restrictions',
    columns: [...this.transactionTypeService.restrictions],
    rowLeftAction: RowLeftAction.multipleRowSelection,
    enablePagination: true,
    paginationOptions: {
      pageSize: 5,
      length: 12,
      pageSizeOptions: [5, 8, 10],
      showLastButton: true,
      showPageSizeOptions: true
    },
    datasource: new MatTableDataSource<RestrictionTable>([]), // EMPTY ARRAY
    noRecordsMessage: 'No Restriction defined'
  };


  public conditionsTableMetadata: BodTableMetadata = {
    title: 'Conditions',
    columns: [...this.transactionTypeService.conditions],
    rowLeftAction: RowLeftAction.multipleRowSelection,
    enablePagination: true,
    paginationOptions: {
      pageSize: 5,
      length: 12,
      pageSizeOptions: [5, 8, 10],
      showLastButton: true,
      showPageSizeOptions: true
    },
    datasource: new MatTableDataSource<ConditionTable>([]), // EMPTY ARRAY
    noRecordsMessage: 'No Condition defined'
  };

  public countersTableMetadata: BodTableMetadata = {
    title: 'Counters',
    columns: [...this.transactionTypeService.counters],
    rowLeftAction: RowLeftAction.multipleRowSelection,
    enablePagination: true,
    paginationOptions: {
      pageSize: 5,
      length: 12,
      pageSizeOptions: [5, 8, 10],
      showLastButton: true,
      showPageSizeOptions: true
    },
    datasource: new MatTableDataSource<CounterTable>([]), // EMPTY ARRAY
    noRecordsMessage: 'No Counter defined'
  };

  public selectedRowSingleSelect: ChannelTable[] = [];

  public channelsDataSingleSelect: BodTableMetadata = {
    title: 'Channels',
    columns: [...this.transactionTypeService.channels], // uses the correct columns
    rowLeftAction: RowLeftAction.multipleRowSelection,
    enablePagination: true,
    paginationOptions: {
      pageSize: 5,
      length: 12,
      pageSizeOptions: [5, 8, 10],
      showLastButton: true,
      showPageSizeOptions: true
    },
    datasource: new MatTableDataSource<ChannelTable>(this.selectedRowSingleSelect),
    noRecordsMessage: 'No Currency defined'
  };




  public onPageAction(event) {
    if (event === PageAction.EDIT) {
      this.messages = [];
      this.modeOptionsSimple = { input: true, reset: false };
      this.pageModeSimple = PageMode.INPUT;
      this.showActionsForSimple = true;
    } else {
      this.checkStatus(false);
      this.modeOptionsSimple = { input: false, reset: true };
      this.pageModeSimple = PageMode.INQUIRY;
      this.rowLevelActionsForBasicEdit[0].disabled = false;
      this.showActionsForSimple = false;
    }
  }
  public checkStatus(status) {
    this.formStatus = status;
  }

  public ConfirmData: BodConfirmDialogModel = {
    title: 'BOD.metadataconfig.title',
    message: 'BOD.metadataconfig.message',
    confirm: 'BOD.metadataconfig.delete',
    dismiss: 'BOD.metadataconfig.cancel'
  };

  public rowLevelActionsForBasicEdit: BodTableAction[] = [
    {
      id: 1,
      icon: 'trash',
      label: 'mbpBod.demo.microsite.tableActions.labels.delete',
      mostCommon: false
    }
  ];

  getRowLevelActionsForBasicEdit(row: any): BodTableAction[] {
    return [
      {
        id: 1,
        icon: 'trash',
        label: 'mbpBod.demo.microsite.tableActions.labels.delete',
        mostCommon: false,
        disabled: row?.code === 'All'
      }
    ];
  }

  public actionsForSimple: BodTableAction[] = [

    { id: 'edit', icon: 'edit', label: 'Edit' }
  ];
  public actionsForChannels: BodTableAction[] = [
    {
      id: BodTableActionType.ADD, // or id: 2, or id: 'add'
      icon: 'add',
      label: 'add',
      mostCommon: false,
      disabled: false // explicitly set

    }
  ];


  attributeForChannels = [
    { label: 'Counters', value: 'Counters' },
    { label: 'Restrictions', value: 'Restrictions' },
    { label: 'Communication Services', value: 'CommunicationServices' },
    { label: 'Conditions', value: 'Conditions' },
  ];

  public channels: any[] = [];


  public columns: Column[] = [
    {
      name: 'channel',
      title: 'Channel',
      width: 2,
      inputModeOptions: {
        type: ColumnType.select,
        model: [],
        validators: {
          required: true,
          max: 50,
          maxLengthStrategy: this.selectedStrategy
        }
      }
    },
    {
      name: 'option',
      title: 'Option',
      width: 2,
      inputModeOptions: {
        type: ColumnType.select,
        model: [
          { label: 'Locked', value: 'Locked' },
          { label: 'Mandatory', value: 'Mandatory' },
          { label: 'Optional', value: 'Optional' },
          { label: 'Proposed', value: 'Proposed' },

        ],
        validators: {
          required: true,
          max: 20,
          maxLengthStrategy: this.selectedStrategy
        }
      }
    },
    {
      name: 'inlineRowEditAction',
      title: ' ',
      disableSorting: true,
      disableFiltering: true,
      hasAction: true,
      width: 3
    },
    {
      name: 'actions',
      title: ' ',
      hasAction: true,
      width: 3
    }
  ];


  public columnSimpleEdit = this.columns;

  public getCurrentTableData(): ChannelTable[] {
    return this.tableWithSimpleEdit?.datasource?.data || [];
  }

  public successMsg: NotificationMessage = {
    code: '200',
    text: this.translate.instant(
      'mbpBod.demo.microsite.table.messages.success'
    ),
    type: NotificationMessageType.SUCCESS,
    closeable: true,
    expandable: false
  };

  public resetMsg: NotificationMessage = {
    code: '200',
    text: this.translate.instant('mbpBod.demo.microsite.table.messages.reset'),
    type: NotificationMessageType.SUCCESS,
    closeable: true,
    expandable: false
  };

  public addNewChannelForm: UntypedFormGroup;

  constructor(
    private transactionTypeService: TransactionTypeService,
    private http: HttpClient,
    private formBuilder: UntypedFormBuilder,
    private translate: TranslateService,
    private bodConfirmAlertDialogsService: BodConfirmAlertDialogsService,
    private formStateService: BodFormStateService,
    private dialog: MatDialog
  ) {
    this.selectedChannelData = [];
    this.addNewChannelForm = this.formBuilder.group({
      id: [''],
      relationshipType: [''],
      condition: [''],
      attributeForChannel: [''],
      // Add other required fields here
    });
  }

  ngOnInit(): void {
    this.loadDropdownData();
    this.loadChannelSearchTable();
    this.onPageAction("");
    this.lastModifiedIndex = this.tableWithSimpleEdit.datasource.data.length;

    if (!this.dataWithSimpleEdit.some(row => row.code === 'All')) {
      const allRow = {
        id: -1, // Use 0 or another unique value that won't clash with real channels
        code: 'All',
        channel: 'All', 
        option: '',
        identifier: '0',
        attributeForChannel: '',
        // Add any other required fields here
      };
      this.dataWithSimpleEdit.unshift(allRow);
      this.tableWithSimpleEdit.datasource.data = [...this.dataWithSimpleEdit];
    }

    this.subscriptions.add(
      this.translate.onTranslationChange.subscribe(lang => {
        const keys = [
          'mbpBod.demo.microsite.table.messages.success',
          'mbpBod.demo.microsite.table.messages.reset'
        ];
        this.translate
          .get(keys)
          .pipe(take(1))
          .subscribe(value => {
            this.successMsg.text = value[keys[0]];
            this.resetMsg.text = value[keys[1]];
          });
      })
    );
  }
  public countersRawData: any[] = [];
  public conditionsRawData: any[] = []; // Store the raw counters


  loadDropdownData(): void {
    this.transactionTypeService.getDeliveryChannel().subscribe((channels: any[]) => {
      const channelValues = channels.map(channel => channel.code);
      this.columns[0].inputModeOptions.model = channelValues;
      this.channels = channels.map(channel => ({
        label: channel.code,
        value: channel.identifier
      }));

      // --- Ensure dialog table gets the latest data ---
      // When setting data for the dialog:
      this.channelsDataSingleSelect.datasource.data = channels.map((channel, idx) => ({
        id: idx + 1,
        code: channel.code,      // for the Channel column
        option: '',               // for the Option column (user will select)
        identifier: channel.identifier
      }));
      // After fetching channels
      console.log('Fetched channels:', JSON.stringify(channels, null, 2));
    });
    this.transactionTypeService.getCounters().subscribe((response: any[]) => {
      this.countersRawData = response;
      // Map your response to the table's expected format if needed
      // this.countersTableMetadata.datasource.data = response.map((counter, idx) => ({
      //   id: idx + 1,
      //   code: counter.code,
      //   identifier: counter.identifier,
      //   classificationType: '', // or default value
      //   operatorType: ''        // or default value
      // }));
      // Optionally, update selectedRowCounters if you want to preselect
      // this.selectedRowCounters = [];
      console.log('Counters response:', JSON.stringify(response, null, 2));
    });
    this.transactionTypeService.getConditions().subscribe((response: any[]) => {
      this.conditionsRawData = response;
      
      console.log('conditions response:', JSON.stringify(response, null, 2));
    });
    this.transactionTypeService.getRestrictions().subscribe((response: any[]) => {
      this.conditionsRawData = response;
      
      console.log('Restrictions response:', JSON.stringify(response, null, 2));
    });
  }

  ngAfterViewInit() {
    this.tableRefArray = [this.simpleEditTableRef];
  }

  ngOnDestroy() {
    this.subscriptions.unsubscribe();
  }

  public singleRowEdit: SingleRowEdit = {
    modeOptions: { input: false, reset: false },
    index: 0
  };

  public dataWithSimpleEdit: ChannelTable[] = [];

  public tableWithSimpleEdit: BodTableMetadata = {
    title: 'Channel Configuration',
    columns: this.columnSimpleEdit,
    datasource: new MatTableDataSource<ChannelTable>(
      this.dataWithSimpleEdit
    ),
    rowLeftAction: RowLeftAction.expandableRows,
    noRecordsMessage: 'No Channel Configuration Defined'
  };

  public dataWithSimpleCounter: CounterTable[] = [];

  public tableWithSimpleCounter: BodTableMetadata = {
    title: 'Counters',
    columns: [...this.transactionTypeService.counters],
    datasource: new MatTableDataSource<CounterTable>(this.dataWithSimpleCounter),
    // enablePagination: true,
    // paginationOptions: {
    //   pageSize: 5,
    //   length: 12,
    //   pageSizeOptions: [5, 8, 10],
    //   showLastButton: true,
    //   showPageSizeOptions: true
    // },
    noRecordsMessage: 'No Counter defined'
  };

  public dataWithSimpleCondition: ConditionTable[] = [];

  public tableWithSimpleCondition: BodTableMetadata = {
    title: 'Conditions',
    columns: [...this.transactionTypeService.conditions],
    datasource: new MatTableDataSource<ConditionTable>(this.dataWithSimpleCondition),
    noRecordsMessage: 'No Condition defined'
  };

  public dataWithSimpleRestriction: RestrictionTable[] = [];

  public tableWithSimpleRestriction: BodTableMetadata = {
    title: 'Restrictions',
    columns: [...this.transactionTypeService.restrictions],
    datasource: new MatTableDataSource<RestrictionTable>(this.dataWithSimpleRestriction),
    noRecordsMessage: 'No Restriction defined'
  };


  public reset() {
    this.modeOptionsSimple = { input: true, reset: true };
    this.updateMsgArr(this.resetMsg);
  }

  updateMsgArr(resetMsg: NotificationMessage) {
    // Implementation for updating message array
  }

  public selectedChannelData: any[] = [];

  generateUniqueId(array: { id: number }[]): number {
    const existingIds = array.map(item => item.id);
    let newId = 1;
    while (existingIds.includes(newId)) {
      newId++;
    }
    return newId;
  }
  onAttributeForChannelChange(event: any) {
    this.addNewChannelForm.markAsDirty();
  }
  // channels-main-table.component.ts

  public newId = this.generateUniqueId(this.tableWithSimpleEdit.datasource.data);

  // Initialize all required fields for the new row
  newRow = {
    id: this.newId,
    relationshipType: '', // or default value
    condition: '',        // or default value
    // ...add all other required fields here
  };

  setDataForSingleLineEditMode(editIndex: number) {
    this.dataForReset = this.tableWithSimpleEdit.datasource.data.map(obj => ({
      ...obj
    }));
    this.singleRowEdit = {
      modeOptions: { input: true, reset: false },
      index: editIndex
    };
    this.pageModeSimple = PageMode.NONE;
  }

  public onAddChannel(formValue: any) {
    // Update the selected row in your dataWithSimpleEdit array
    const index = this.dataWithSimpleEdit.findIndex(row => row.id === formValue.id);
    if (index !== -1) {
      this.dataWithSimpleEdit[index] = { ...formValue };
      this.tableWithSimpleEdit.datasource.data = [...this.dataWithSimpleEdit];
    }
  }

  public onSaveChannelRow(_: any) {
    const formValue = this.addNewChannelForm.value;
    const rowId = formValue.id;
    const index = this.dataWithSimpleEdit.findIndex(row => row.id === rowId);

    // Validation example for counters (if needed)
    if (this.addNewChannelForm.get('attributeForChannel')?.value === 'Counters') {
      // Example: check for empty counters
      if (!this.dataWithSimpleCounter || this.dataWithSimpleCounter.length === 0) {
        // Handle error (show message, etc.)
        console.error('No counters selected!');
        return;
      }
    }

    // Update the row with form and counters data
    if (index !== -1) {
      const savedRow = {
        ...this.dataWithSimpleEdit[index],
        ...formValue,
        attributeForChannel: this.addNewChannelForm.get('attributeForChannel')?.value,
        counters: [...this.dataWithSimpleCounter]
      };
      // Print/log what you are saving
      console.log('Saving row:', savedRow);

      this.dataWithSimpleEdit[index] = savedRow;
      this.tableWithSimpleEdit.datasource.data = [...this.dataWithSimpleEdit];
    }

    // Optionally reset edit mode or close modal
    this.singleRowEdit = { modeOptions: { input: false, reset: false }, index: -1 };
    this.emitCompleteDelta();
  }




  public addTableData() {
    const dialogRef = this.dialog.open(ChannelsMultiselectDialogComponent, {
      width: '900px',
      height: '600px',
      data: {
        channelsDataSingleSelect: this.channelsDataSingleSelect,
        selectedRowSingleSelect: this.selectedRowSingleSelect // pass current selection if needed
      }
    });
    dialogRef.componentInstance.tableDirty.subscribe(() => {
      this.addNewChannelForm.markAsDirty();
    });
    dialogRef.afterClosed().subscribe(result => {
      if (result?.selectedChannels) {
        const currentAttr = this.addNewChannelForm.get('attributeForChannel')?.value || '';
        const mapped = result.selectedChannels.map(row => ({
          id: row.id,
          option: row.option,
          channel: row.code,
          identifier: row.identifier,
          attributeForChannel: currentAttr
        }));
  
        // --- Ensure "All" row is always present at the top ---
        const allRow = this.dataWithSimpleEdit.find(row => row.code === 'All' );
        let newData: any[] = [];
        if (allRow) {
          newData = [allRow, ...mapped.filter(row => (row.code ?? row.channel) !== 'All')];
        } else {
          // fallback: create a new "All" row if not present
          newData = [{
            id: -1,
            code: 'All',
            channel: 'All',
            option: '',
            identifier: '0',
            attributeForChannel: currentAttr
          }, ...mapped.filter(row => (row.code ?? row.channel) !== 'All')];
        }
  
        this.dataWithSimpleEdit = newData;
        this.tableWithSimpleEdit.datasource.data = [...newData];
        this.channelData = [...newData];
        this.emitCompleteDelta();
      }
    });
  }

  addCounterTableData() {
    this.addNewChannelForm.markAsDirty();
    this.transactionTypeService.getCounters().subscribe((response: any[]) => {
      const dialogTableMetadata: BodTableMetadata = {
        ...this.countersTableMetadata,
        datasource: new MatTableDataSource<CounterTable>(
          response.map((counter, idx) => ({
            id: idx + 1,
            code: counter.code,
            identifier: counter.identifier,
            classificationType: counter.classificationType,
            operatorType: ''
          }))
        )
      };

      // Use the counters for the current row
      const selectedCounters = this.counterMap[this.currentChannelRowId!] || [];

      const dialogRef = this.dialog.open(CountersMultiselectDialogComponent, {
        width: '1000px',
        height: '600px',
        data: {
          countersDataSingleSelect: dialogTableMetadata,
          selectedRowSingleSelect: selectedCounters
        }
      });

      dialogRef.afterClosed().subscribe(result => {
        if (result?.selectedCounters) {
          const mapped = result.selectedCounters.map(row => ({
            id: row.id,
            code: row.code,
            identifier: row.identifier,
            classificationType: row.classificationType,
            operatorType: row.operatorType
          }));
          // Store counters for this channel row only
          this.counterMap[this.currentChannelRowId!] = mapped;
          // Update the UI for the current row
          this.dataWithSimpleCounter = mapped;
          this.tableWithSimpleCounter.datasource.data = [...mapped];
          // Optionally update the row in dataWithSimpleEdit
          const idx = this.dataWithSimpleEdit.findIndex(r => r.id === this.currentChannelRowId);
          if (idx !== -1) {
            this.dataWithSimpleEdit[idx].counters = mapped;
          }
          this.counterDetails.emit(mapped);
        }
      });
    });
  }

  addConditionTableData() {
    this.addNewChannelForm.markAsDirty();
    this.transactionTypeService.getConditions().subscribe((response: any[]) => {
      const dialogTableMetadata: BodTableMetadata = {
        ...this.conditionsTableMetadata,
        datasource: new MatTableDataSource<ConditionTable>(
          response.map((condition, idx) => ({
            id: idx + 1,
            code: condition.cdarValue,
            identifier: condition.identifier,
            relationshipType: ''
          }))
        )
      };
  
      // Use the conditions for the current row
      const selectedConditions = this.conditionMap[this.currentChannelRowId!] || [];
  
      const dialogRef = this.dialog.open(ConditionsMultiselectDialogComponent, {
        width: '1000px',
        height: '600px',
        data: {
          conditionsDataSingleSelect: dialogTableMetadata,
          selectedRowSingleSelect: selectedConditions
        }
      });
  
      dialogRef.afterClosed().subscribe(result => {
        if (result?.selectedConditions) {
          const mapped = result.selectedConditions.map(row => ({
            id: row.id,
            code: row.code,
            identifier: row.identifier,
            relationshipType: row.relationshipType
          }));
          // Store conditions for this channel row only
          this.conditionMap[this.currentChannelRowId!] = mapped;
          // Update the UI for the current row
          this.dataWithSimpleCondition = mapped;
          this.tableWithSimpleCondition.datasource.data = [...mapped];
          // Optionally update the row in dataWithSimpleEdit
          const idx = this.dataWithSimpleEdit.findIndex(r => r.id === this.currentChannelRowId);
          if (idx !== -1) {
            this.dataWithSimpleEdit[idx].conditions = mapped;
          }
          this.conditionDetails.emit(mapped);
        }
      });
    });
  }

   // Add this method
   handleConditionRowLevelActions($event: any, index: number) {
    if ($event === 'trash') {
      // Remove the row from your data array
      this.dataWithSimpleCondition.splice(index, 1);
      // Update the table datasource
      this.tableWithSimpleCondition.datasource.data = [...this.dataWithSimpleCondition];
      // Emit the updated data if needed
      this.conditionDetails.emit(this.dataWithSimpleCondition);
    }
    this.addNewChannelForm.markAsDirty();
    // You can add 'edit' or 'save' logic here if needed
  }

  addRestrictionTableData() {
    this.addNewChannelForm.markAsDirty();
    this.transactionTypeService.getRestrictions().subscribe((response: any[]) => {
      const dialogTableMetadata: BodTableMetadata = {
        ...this.restrictionsTableMetadata,
        datasource: new MatTableDataSource<RestrictionTable>(
          response.map((restriction, idx) => ({
            id: idx + 1,
            code: restriction.code,
            identifier: restriction.identifier,
            type: 'ERROR'
          }))
        )
      };
  
      // Use the restrictions for the current row
      const selectedRestrictions = this.restrictionMap[this.currentChannelRowId!] || [];
  
      const dialogRef = this.dialog.open(RestrictionsMultiselectDialogComponent, {
        width: '1000px',
        height: '600px',
        data: {
          restrictionsDataSingleSelect: dialogTableMetadata,
          selectedRowSingleSelect: selectedRestrictions
        }
      });
  
      dialogRef.afterClosed().subscribe(result => {
        if (result?.selectedRestrictions) {
          const mapped = result.selectedRestrictions.map(row => ({
            id: row.id,
            code: row.code,
            identifier: row.identifier,
            type: row.type
          }));
          // Store restrictions for this channel row only
          this.restrictionMap[this.currentChannelRowId!] = mapped;
          // Update the UI for the current row
          this.dataWithSimpleRestriction = mapped;
          this.tableWithSimpleRestriction.datasource.data = [...mapped];
          // Optionally update the row in dataWithSimpleEdit
          const idx = this.dataWithSimpleEdit.findIndex(r => r.id === this.currentChannelRowId);
          if (idx !== -1) {
            this.dataWithSimpleEdit[idx].restrictions = mapped;
          }
          this.restrictionDetails.emit(mapped);
        }
      });
    });
  }

  // Add this method
  handleRestrictionRowLevelActions($event: any, index: number) {
    if ($event === 'trash') {
      // Remove the row from your data array
      this.dataWithSimpleRestriction.splice(index, 1);
      // Update the table datasource
      this.tableWithSimpleRestriction.datasource.data = [...this.dataWithSimpleRestriction];
      // Emit the updated data if needed
      this.restrictionDetails.emit(this.dataWithSimpleRestriction);
    }
    this.addNewChannelForm.markAsDirty();
    // You can add 'edit' or 'save' logic here if needed
  }

  public channelObject: any = {};
  public channelObjectsArray: any[] = [];

  public resetTableForm() {
    this.channelObject = {};
    this.channelObjectsArray = [];
    this.dataWithSimpleEdit = [];
    this.tableWithSimpleEdit.datasource.data = [];

    setTimeout(() => {
      this.simpleEditTableRef?.tableFormGroup.reset();
      this.formStateService.formState$.next(false);
    });
    console.log("resetting channel table");
  }



  handleRowLevelActions($event: any, index: any) {
    if ($event === 'edit') {
      const row = this.dataWithSimpleEdit[index];
      this.addNewChannelForm.patchValue(row);
    } else if ($event === 'trash') {
      if (this.modeOptionsSimple?.input) {
        this.deleteTableData(index);
      } else {
        this.subscriptions.add(
          this.bodConfirmAlertDialogsService
            .confirm(this.ConfirmData)
            .subscribe(val => {
              if (val) {
                this.deleteTableData(index);
              }
            })
        );
      }
    } else if ($event === 'save') {
      this.singleRowEdit = {
        modeOptions: { input: false, reset: false },
        index: 0
      };
      this.pageModeSimple = PageMode.INQUIRY;
      this.rowLevelActionsForBasicEdit[0].disabled = false;

      const updatedRow = this.channelObject as ChannelTable;
      const allRows = this.tableWithSimpleEdit.datasource.data as ChannelTable[];

      console.log('%c📝 DEBUG: channelObject:', 'color: cyan', updatedRow);
      console.log('%c📋 DEBUG: All Rows Before Update:', 'color: orange', [...allRows]);

      const existingIndex = allRows.findIndex(row => row.id === updatedRow.id);

      if (existingIndex !== -1) {
        console.log(`🔄 Updating row at index ${existingIndex}`);
        allRows[existingIndex] = { ...updatedRow };
      } else {
        console.warn('⚠️ Row not found, pushing new one:', updatedRow);
        allRows.push(updatedRow);
      }

      this.channelObjectsArray = [...allRows];

      console.log('%c✅ DEBUG: Final channelObjectsArray to emit:', 'color: green', this.channelObjectsArray);

      this.channelDetails.emit(this.channelObjectsArray);

      this.updateFormStateAsPristine();
    }
  }

  handleCounterRowLevelActions($event: any, index: number) {
    if ($event === 'trash') {
      // Remove the row from your data array
      this.dataWithSimpleCounter.splice(index, 1);
      // Update the table datasource
      this.tableWithSimpleCounter.datasource.data = [...this.dataWithSimpleCounter];
      // Emit the updated data if needed
      this.counterDetails.emit(this.dataWithSimpleCounter);
    }
    this.addNewChannelForm.markAsDirty();
    // You can add 'edit' or 'save' logic here if needed
  }

  private updateFormStateAsPristine() {
    switch (this.selectedTabIndex) {
      case 0: {
        this.simpleEditTableRef?.tableFormGroup.markAsPristine();
        this.formStateService.formState$.next(
          this.simpleEditTableRef.tableFormGroup.dirty
        );
        break;
      }
      default:
        break;
    }
  }

  public deleteTableData(index) {
    switch (this.selectedTabIndex) {
      case 0: {
        this.simpleEditTableRef.deleteRow(index);
        break;
      }
      default:
        break;
    }
    this.emitCompleteDelta();
  }

  public searchChannelInput = '';
  public searchFieldDataForChannel: BodSearchFieldData = {
    label: 'Channel',
    fieldName: 'code',
    descFieldName: '',
    required: true,
    allowOtherInputs: false,
    hideFilterCriteria: false,
    disableInput: false
  };
  public tableDataForChannel: BodTableMetadata = {
    columns: [{ name: 'code' }],
    datasource: new MatTableDataSource<any>([]), // Will be filled with channel data
  };

  private loadChannelSearchTable() {
    this.transactionTypeService.getDeliveryChannel().subscribe((channels: any[]) => {
      this.tableDataForChannel.datasource.data = channels;
    });
  }

  // Called when a channel is selected from the search field
  public onChannelSearchChange(selectedCode: string) {
    const selected = this.tableDataForChannel.datasource.data.find(
      (item: any) => item.code === selectedCode
    );
    if (selected) {
      // Add to your table (avoid duplicates if needed)
      const exists = this.dataWithSimpleEdit.some(row => row.code === selected.code);
      if (!exists) {
        this.dataWithSimpleEdit.push({
          id: this.generateUniqueId(this.dataWithSimpleEdit),
          code: selected.code,
          option: '',
          attributeForChannel: this.addNewChannelForm.get('attributeForChannel')?.value || ''
        });
        this.tableWithSimpleEdit.datasource.data = [...this.dataWithSimpleEdit];
      }
      this.searchChannelInput = ''; // Reset input after add
    }
  }

  public onCancelChannelRow() {
    // Close the inline modal
    this.singleRowEdit = { modeOptions: { input: false, reset: false }, index: -1 };
    // Enable all row actions
    this.rowLevelActionsForBasicEdit.forEach(action => action.disabled = false);
    // Optionally reset the form if needed
    this.addNewChannelForm.reset();
  }


  public editIndex = -1;
  public editRowElement: any;

  public currentChannelRowId: number | null = null;

  inlineEditRowActionClick(
    inlineEditOutput: InlineEditOutput,
    index: number,
    template?: any
  ) {
    const element = (this.editRowElement = inlineEditOutput.editRowElement);

    if (element && element.id) {
      this.addNewChannelForm.reset();
      this.addNewChannelForm.patchValue(element);
      this.currentChannelRowId = element.id; // Track the channel row being edited
    }

    this.editIndex = inlineEditOutput.editRowIndex ?? index;

    this.singleRowEdit = {
      modeOptions: { input: true, reset: false },
      index: this.editIndex
    };

    // Load counters for this channel row if you have them stored
    this.dataWithSimpleCounter = this.counterMap?.[element.id] ? [...this.counterMap[element.id]] : [];
    this.tableWithSimpleCounter.datasource.data = this.dataWithSimpleCounter;

     // Load conditions for this channel row if you have them stored
     this.dataWithSimpleCondition = this.conditionMap?.[element.id] ? [...this.conditionMap[element.id]] : [];
     this.tableWithSimpleCondition.datasource.data = this.dataWithSimpleCondition;

      // Load restrictions for this channel row if you have them stored
    this.dataWithSimpleRestriction = this.restrictionMap?.[element.id] ? [...this.restrictionMap[element.id]] : [];
    this.tableWithSimpleRestriction.datasource.data = this.dataWithSimpleRestriction;
  }
  public getAllCountersWithChannelIdentifier(): any[] {
    // Flatten all counters from all channels, adding channelidentifier to each
    return (this.dataWithSimpleEdit || [])
      .filter(channel => Array.isArray(channel.counters))
      .map(channel =>
        (channel.counters ?? []).map(counter => ({
          ...counter,
          channelidentifier: channel.identifier
        }))
      )
      .reduce((acc, val) => acc.concat(val), []);
  }

  // Update the getAllCountersWithChannelIdentifier method to include conditions
  public getAllConditionsWithChannelIdentifier(): any[] {
    // Flatten all conditions from all channels, adding channelidentifier to each
    return (this.dataWithSimpleEdit || [])
      .filter(channel => Array.isArray(channel.conditions))
      .map(channel =>
        (channel.conditions ?? []).map(condition => ({
          ...condition,
          channelidentifier: channel.identifier
        }))
      )
      .reduce((acc, val) => acc.concat(val), []);
  }

  // Update the getAllCountersWithChannelIdentifier method to include restrictions
  public getAllRestrictionsWithChannelIdentifier(): any[] {
    // Flatten all restrictions from all channels, adding channelidentifier to each
    return (this.dataWithSimpleEdit || [])
      .filter(channel => Array.isArray(channel.restrictions))
      .map(channel =>
        (channel.restrictions ?? []).map(restriction => ({
          ...restriction,
          channelidentifier: channel.identifier
        }))
      )
      .reduce((acc, val) => acc.concat(val), []);
  }
  public countersTableColumns = [
    { name: 'counter', title: 'Counter' },
    { name: 'classificationType', title: 'Classification Type' },
    { name: 'operatorType', title: 'Operator Type' },
    { name: 'actions', title: '' }
  ];
  public countersTableActions = [
    { id: 'edit', icon: 'edit', label: 'Edit' }
  ];
}
