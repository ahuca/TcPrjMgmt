function Import-ModuleUnderTest {
    [CmdletBinding]

    Import-Module "$PSScriptRoot\..\src\TcPrjMgmt"
}

Import-ModuleUnderTest

$script:TestPlcProject = 'TestPlcProject'
$script:TestXaeProject = Resolve-Path "$PSScriptRoot\TestXaeProject"
$script:TestXaeSolutionFile = Resolve-Path "$TestXaeProject\TestXaeProject.sln"
$script:TestPlcLibraryPath = Resolve-Path "$TestXaeProject\TestPlcProject.library"
$script:PlcProjectExtension = ".plcproj"
$script:PlcProjectExampleContent = '<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
<PropertyGroup>
  <FileVersion>1.0.0.0</FileVersion>
  <SchemaVersion>2.0</SchemaVersion>
  <ProjectGuid>{ddd0323b-cabb-4026-8d96-1a7555efda37}</ProjectGuid>
  <SubObjectsSortedByName>True</SubObjectsSortedByName>
  <DownloadApplicationInfo>true</DownloadApplicationInfo>
  <WriteProductVersion>true</WriteProductVersion>
  <GenerateTpy>false</GenerateTpy>
  <Name>TestPlcProject</Name>
  <ProgramVersion>3.1.4023.0</ProgramVersion>
  <Application>{ed8c55b7-bcd0-4992-ad26-706e4bb58a68}</Application>
  <TypeSystem>{eeb0ecc0-0514-4e13-a92e-ca66e4a35164}</TypeSystem>
  <Implicit_Task_Info>{3a7400f8-3846-4a4b-bcd0-cc9ea2629e0f}</Implicit_Task_Info>
  <Implicit_KindOfTask>{502bacac-06aa-4f7c-a043-d8af78d996e1}</Implicit_KindOfTask>
  <Implicit_Jitter_Distribution>{6429156c-4534-4492-9f0f-19f37a369843}</Implicit_Jitter_Distribution>
  <LibraryReferences>{619b22dc-c268-4304-afcf-008c3ee59153}</LibraryReferences>
  <Company>TestPlcProject</Company>
  <Released>false</Released>
  <Title>TestPlcProject</Title>
  <ProjectVersion>0.1.0</ProjectVersion>
</PropertyGroup>
<ItemGroup>
  <Compile Include="PlcTask.TcTTO">
    <SubType>Code</SubType>
  </Compile>
  <Compile Include="POUs\FB_TestFb1.TcPOU">
    <SubType>Code</SubType>
  </Compile>
  <Compile Include="POUs\MAIN.TcPOU">
    <SubType>Code</SubType>
  </Compile>
</ItemGroup>
<ItemGroup>
  <Folder Include="DUTs" />
  <Folder Include="GVLs" />
  <Folder Include="VISUs" />
  <Folder Include="POUs" />
</ItemGroup>
<ItemGroup>
  <PlaceholderReference Include="Tc2_Standard">
    <DefaultResolution>Tc2_Standard, * (Beckhoff Automation GmbH)</DefaultResolution>
    <Namespace>Tc2_Standard</Namespace>
  </PlaceholderReference>
  <PlaceholderReference Include="Tc2_System">
    <DefaultResolution>Tc2_System, * (Beckhoff Automation GmbH)</DefaultResolution>
    <Namespace>Tc2_System</Namespace>
  </PlaceholderReference>
  <PlaceholderReference Include="Tc3_Module">
    <DefaultResolution>Tc3_Module, * (Beckhoff Automation GmbH)</DefaultResolution>
    <Namespace>Tc3_Module</Namespace>
  </PlaceholderReference>
</ItemGroup>
<ProjectExtensions>
  <PlcProjectOptions>
    <XmlArchive>
      <Data>
        <o xml:space="preserve" t="OptionKey">
    <v n="Name">"&lt;ProjectRoot&gt;"</v>
    <d n="SubKeys" t="Hashtable" ckt="String" cvt="OptionKey">
      <v>{40450F57-0AA3-4216-96F3-5444ECB29763}</v>
      <o>
        <v n="Name">"{40450F57-0AA3-4216-96F3-5444ECB29763}"</v>
        <d n="SubKeys" t="Hashtable" />
        <d n="Values" t="Hashtable" ckt="String" cvt="String">
          <v>ActiveVisuProfile</v>
          <v>IR0whWr8bwfwBwAAiD2qpQAAAABVAgAA37x72QAAAAABAAAAAAAAAAEaUwB5AHMAdABlAG0ALgBTAHQAcgBpAG4AZwACTHsAZgA5ADUAYgBiADQAMgA2AC0ANQA1ADIANAAtADQAYgA0ADUALQA5ADQAMAAwAC0AZgBiADAAZgAyAGUANwA3AGUANQAxAGIAfQADCE4AYQBtAGUABDBUAHcAaQBuAEMAQQBUACAAMwAuADEAIABCAHUAaQBsAGQAIAA0ADAAMgA0AC4ANwAFFlAAcgBvAGYAaQBsAGUARABhAHQAYQAGTHsAMQA2AGUANQA1AGIANgAwAC0ANwAwADQAMwAtADQAYQA2ADMALQBiADYANQBiAC0ANgAxADQANwAxADMAOAA3ADgAZAA0ADIAfQAHEkwAaQBiAHIAYQByAGkAZQBzAAhMewAzAGIAZgBkADUANAA1ADkALQBiADAANwBmAC0ANABkADYAZQAtAGEAZQAxAGEALQBhADgAMwAzADUANgBhADUANQAxADQAMgB9AAlMewA5AGMAOQA1ADgAOQA2ADgALQAyAGMAOAA1AC0ANAAxAGIAYgAtADgAOAA3ADEALQA4ADkANQBmAGYAMQBmAGUAZABlADEAYQB9AAoOVgBlAHIAcwBpAG8AbgALBmkAbgB0AAwKVQBzAGEAZwBlAA0KVABpAHQAbABlAA4aVgBpAHMAdQBFAGwAZQBtAE0AZQB0AGUAcgAPDkMAbwBtAHAAYQBuAHkAEAxTAHkAcwB0AGUAbQARElYAaQBzAHUARQBsAGUAbQBzABIwVgBpAHMAdQBFAGwAZQBtAHMAUwBwAGUAYwBpAGEAbABDAG8AbgB0AHIAbwBsAHMAEyhWAGkAcwB1AEUAbABlAG0AcwBXAGkAbgBDAG8AbgB0AHIAbwBsAHMAFCRWAGkAcwB1AEUAbABlAG0AVABlAHgAdABFAGQAaQB0AG8AcgAVIlYAaQBzAHUATgBhAHQAaQB2AGUAQwBvAG4AdAByAG8AbAAWFHYAaQBzAHUAaQBuAHAAdQB0AHMAFwxzAHkAcwB0AGUAbQAYGFYAaQBzAHUARQBsAGUAbQBCAGEAcwBlABkmRABlAHYAUABsAGEAYwBlAGgAbwBsAGQAZQByAHMAVQBzAGUAZAAaCGIAbwBvAGwAGyJQAGwAdQBnAGkAbgBDAG8AbgBzAHQAcgBhAGkAbgB0AHMAHEx7ADQAMwBkADUAMgBiAGMAZQAtADkANAAyAGMALQA0ADQAZAA3AC0AOQBlADkANAAtADEAYgBmAGQAZgAzADEAMABlADYAMwBjAH0AHRxBAHQATABlAGEAcwB0AFYAZQByAHMAaQBvAG4AHhRQAGwAdQBnAGkAbgBHAHUAaQBkAB8WUwB5AHMAdABlAG0ALgBHAHUAaQBkACBIYQBmAGMAZAA1ADQANAA2AC0ANAA5ADEANAAtADQAZgBlADcALQBiAGIANwA4AC0AOQBiAGYAZgBlAGIANwAwAGYAZAAxADcAIRRVAHAAZABhAHQAZQBJAG4AZgBvACJMewBiADAAMwAzADYANgBhADgALQBiADUAYwAwAC0ANABiADkAYQAtAGEAMAAwAGUALQBlAGIAOAA2ADAAMQAxADEAMAA0AGMAMwB9ACMOVQBwAGQAYQB0AGUAcwAkTHsAMQA4ADYAOABmAGYAYwA5AC0AZQA0AGYAYwAtADQANQAzADIALQBhAGMAMAA2AC0AMQBlADMAOQBiAGIANQA1ADcAYgA2ADkAfQAlTHsAYQA1AGIAZAA0ADgAYwAzAC0AMABkADEANwAtADQAMQBiADUALQBiADEANgA0AC0ANQBmAGMANgBhAGQAMgBiADkANgBiADcAfQAmFk8AYgBqAGUAYwB0AHMAVAB5AHAAZQAnVFUAcABkAGEAdABlAEwAYQBuAGcAdQBhAGcAZQBNAG8AZABlAGwARgBvAHIAQwBvAG4AdgBlAHIAdABpAGIAbABlAEwAaQBiAHIAYQByAGkAZQBzACgQTABpAGIAVABpAHQAbABlACkUTABpAGIAQwBvAG0AcABhAG4AeQAqHlUAcABkAGEAdABlAFAAcgBvAHYAaQBkAGUAcgBzACs4UwB5AHMAdABlAG0ALgBDAG8AbABsAGUAYwB0AGkAbwBuAHMALgBIAGEAcwBoAHQAYQBiAGwAZQAsEnYAaQBzAHUAZQBsAGUAbQBzAC1INgBjAGIAMQBjAGQAZQAxAC0AZAA1AGQAYwAtADQAYQAzAGIALQA5ADAANQA0AC0AMgAxAGYAYQA3ADUANgBhADMAZgBhADQALihJAG4AdABlAHIAZgBhAGMAZQBWAGUAcgBzAGkAbwBuAEkAbgBmAG8AL0x7AGMANgAxADEAZQA0ADAAMAAtADcAZgBiADkALQA0AGMAMwA1AC0AYgA5AGEAYwAtADQAZQAzADEANABiADUAOQA5ADYANAAzAH0AMBhNAGEAagBvAHIAVgBlAHIAcwBpAG8AbgAxGE0AaQBuAG8AcgBWAGUAcgBzAGkAbwBuADIMTABlAGcAYQBjAHkAMzBMAGEAbgBnAHUAYQBnAGUATQBvAGQAZQBsAFYAZQByAHMAaQBvAG4ASQBuAGYAbwA0MEwAbwBhAGQATABpAGIAcgBhAHIAaQBlAHMASQBuAHQAbwBQAHIAbwBqAGUAYwB0ADUaQwBvAG0AcABhAHQAaQBiAGkAbABpAHQAeQDQAAIaA9ADAS0E0AUGGgfQBwgaAUUHCQjQAAkaBEUKCwQDAAAABQAAAA0AAAAAAAAA0AwLrQIAAADQDQEtDtAPAS0Q0AAJGgRFCgsEAwAAAAUAAAANAAAAKAAAANAMC60BAAAA0A0BLRHQDwEtENAACRoERQoLBAMAAAAFAAAADQAAAAAAAADQDAutAgAAANANAS0S0A8BLRDQAAkaBEUKCwQDAAAABQAAAA0AAAAUAAAA0AwLrQIAAADQDQEtE9APAS0Q0AAJGgRFCgsEAwAAAAUAAAANAAAAAAAAANAMC60CAAAA0A0BLRTQDwEtENAACRoERQoLBAMAAAAFAAAADQAAAAAAAADQDAutAgAAANANAS0V0A8BLRDQAAkaBEUKCwQDAAAABQAAAA0AAAAAAAAA0AwLrQIAAADQDQEtFtAPAS0X0AAJGgRFCgsEAwAAAAUAAAANAAAAKAAAANAMC60EAAAA0A0BLRjQDwEtENAZGq0BRRscAdAAHBoCRR0LBAMAAAAFAAAADQAAAAAAAADQHh8tINAhIhoCRSMkAtAAJRoFRQoLBAMAAAADAAAAAAAAAAoAAADQJgutAAAAANADAS0n0CgBLRHQKQEtENAAJRoFRQoLBAMAAAADAAAAAAAAAAoAAADQJgutAQAAANADAS0n0CgBLRHQKQEtEJoqKwFFAAEC0AABLSzQAAEtF9AAHy0t0C4vGgPQMAutAQAAANAxC60XAAAA0DIarQDQMy8aA9AwC60CAAAA0DELrQMAAADQMhqtANA0Gq0A0DUarQA=</v>
        </d>
      </o>
      <v>{192FAD59-8248-4824-A8DE-9177C94C195A}</v>
      <o>
        <v n="Name">"{192FAD59-8248-4824-A8DE-9177C94C195A}"</v>
        <d n="SubKeys" t="Hashtable" />
        <d n="Values" t="Hashtable" />
      </o>
    </d>
    <d n="Values" t="Hashtable" />
  </o>
      </Data>
      <TypeList>
        <Type n="Hashtable">System.Collections.Hashtable</Type>
        <Type n="OptionKey">{54dd0eac-a6d8-46f2-8c27-2f43c7e49861}</Type>
        <Type n="String">System.String</Type>
      </TypeList>
    </XmlArchive>
  </PlcProjectOptions>
</ProjectExtensions>
</Project>'