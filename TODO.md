1. Add code to check success authorization
2. Add code to set credentials for trackers
3. Add code to set destination for downloading files
4. Add code to set credentials for transmission
5. Write tests for code
6. Add possibility to register new adapters
7. Code for parsing search results should be in own classes
8. Solve the issue with encoding
9. Add code to catch an error while parsing HTML
10. Think about creating PostProcessor to avoid converting any data in parsers (we parse seeds to integer in each parser)
11. Think about creating only Extractors instead of parsers. Parser file may be the same for each adapter, but since we need to PreProcess data for some parsers, we need to think about this option as well.
12. Check what will happen if login and password are incorrect for an adapter.
13. Authorizer must check correct status code.